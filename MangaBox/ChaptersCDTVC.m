//
//  ChaptersCDTVC.m
//  MangaBox
//
//  Created by Ken Tran on 11/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "ChaptersCDTVC.h"
#import "Chapter+Download.h"
#import "Manga.h"
#import "Page+Create.h"
#import "Page+Getter.h"
#import "CoverImage.h"
#import "ImageViewController.h"
#import "ChapterPageViewController.h"
#import "MangaDictionaryDefinition.h"
#import "MangaBoxNotification.h"
#import "MangafoxFetcher.h"
#import "MangareaderFetcher.h"
#import "MangaBoxAppDelegate.h"
#import "ChapterViewController.h"
#import "Chapter+UpdateInfo.h"

@interface ChaptersCDTVC() <UIActionSheetDelegate>
@property (nonatomic, strong) NSURLSession *chapterDownloadSession;
@end

@implementation ChaptersCDTVC

#pragma mark - Properties

- (NSURLSession *)chapterDownloadSession
{
    if (!_chapterDownloadSession) {
    //    static dispatch_once_t onceToken;
    //    dispatch_once(&onceToken, ^{
            //NSLog(@"initializing");
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
            _chapterDownloadSession = [NSURLSession sessionWithConfiguration:configuration];
    //    });
    }
    return _chapterDownloadSession;
}

#pragma mark - UITableViewDataSource

#define TITLE_LABEL_TAG 1
#define PAGES_LABEL_TAG 2
#define PROGRESS_BAR_TAG 3
#define STAR_IMAGE_TAG 4


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Chapter Cell"];
    [self configure:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - NSFetchedResultsControllerDelegate

// Overiding delegate defined in CoreDataTableViewController
- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configure:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            //[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)configure:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        Chapter *chapter = [self.fetchedResultsController objectAtIndexPath:indexPath];
        UILabel *title, *pages;
        title = (UILabel *)[cell.contentView viewWithTag:TITLE_LABEL_TAG];
        title.text = chapter.name;
        pages = (UILabel *)[cell.contentView viewWithTag:PAGES_LABEL_TAG];
        
        UIImageView *startImageView = (UIImageView *)[cell viewWithTag:STAR_IMAGE_TAG];
        if ([chapter.bookmark boolValue] == NO) {
            startImageView.image = [UIImage imageNamed:@"emptyStar"];
        } else {
            startImageView.image = [UIImage imageNamed:@"filledStar"];
        }
        
        UIProgressView *progressBar = (UIProgressView *)[cell.contentView viewWithTag:PROGRESS_BAR_TAG];
        
        if ([chapter.downloadStatus isEqualToString:CHAPTER_NEED_DOWNLOAD]) {
            pages.text = @"Please download to read";
            progressBar.hidden = YES;
        } else if ([chapter.downloadStatus isEqualToString:CHAPTER_DOWNLOADED]) {
            progressBar.hidden = YES;
            pages.text = [NSString stringWithFormat:@"Downloaded %lu/%@", (unsigned long)[chapter.pages count], chapter.pagesCount];
        } else if ([chapter.downloadStatus isEqualToString:CHAPTER_DOWNLOADING]) {
            pages.text = [NSString stringWithFormat:@"Downloading... %lu/%@", (unsigned long)[chapter.pages count], chapter.pagesCount];
            
            // Add progress bar for downloading view
            //progressBar.hidden = NO;
            //progressBar.progress = [chapter.pages count] / [chapter.pagesCount doubleValue];
        } else if ([chapter.downloadStatus isEqualToString:CHAPTER_STOPPED_DOWNLOADING]) {
            progressBar.hidden = YES;
            pages.text = [NSString stringWithFormat:@"Download stopped... %lu/%@", (unsigned long)[chapter.pages count], chapter.pagesCount];
        } else {
            pages.text = [NSString stringWithFormat:@"%lu/%@ Pages", (unsigned long)[chapter.pages count], chapter.pagesCount];
            progressBar.hidden = YES;
        }
        
    });
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *choice = [actionSheet buttonTitleAtIndex:buttonIndex];
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    Chapter *chapter = [self.fetchedResultsController objectAtIndexPath:indexPath];

    if ([choice isEqualToString:@"Download"]) {
        chapter.downloadStatus = CHAPTER_DOWNLOADING;
        [self startDownloadingChapter:chapter];
    } else if ([choice isEqualToString:@"Read"] || [choice isEqualToString:@"Read and Download"]) {
        id detailvc = [self.splitViewController.viewControllers lastObject];
        if ([detailvc isKindOfClass:[UINavigationController class]]) {
            detailvc = [((UINavigationController *)detailvc).viewControllers firstObject];
            [self prepareViewController:detailvc
                               forSegue:nil
                          fromIndexPath:indexPath];
        }
        [self performSegueWithIdentifier:@"Show Pages" sender:actionSheet];
    } else if ([choice isEqualToString:@"Bookmark"]) {
        [chapter addBookmark];
    } else if ([choice isEqualToString:@"Remove Bookmark"]) {
        [chapter removeBookmark];
    } else if ([choice isEqualToString:@"Stop downloading"]) {
        [self stopDownloadingChapter:chapter];
    }
}

#pragma mark - Alerts

- (void)alert:(NSString *)msg
{
    [[[UIAlertView alloc] initWithTitle:@"Error"
                                message:msg
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
}

#pragma mark - Error Observer

- (void)prepareForAlert:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self alert:[notification.userInfo objectForKey:@"msg"]];
    });
}

#pragma mark - Navigation

- (void)prepareViewController:(id)vc forSegue:(NSString *)segueIdentifer fromIndexPath:(NSIndexPath *)indexPath
{
    Chapter *chapter = [self.fetchedResultsController objectAtIndexPath:indexPath];
    // note that we don't check the segue identifier here
    // probably fine ... hard to imagine any other way this class would segue to PhotosByPhotographerCDTVC
    if ([vc isKindOfClass:[ChapterViewController class]]) {
        ChapterViewController *chapterPVC = (ChapterViewController *)vc;
        chapterPVC.title = chapter.name;
        chapterPVC.chapter = chapter;
        chapterPVC.hidesBottomBarWhenPushed = YES;
    }
}

// boilerplate
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = nil;
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        indexPath = [self.tableView indexPathForCell:sender];
    } else if ([sender isKindOfClass:[UIActionSheet class]]) {
        indexPath = [self.tableView indexPathForSelectedRow];
    }
    [self prepareViewController:segue.destinationViewController
                       forSegue:segue.identifier
                  fromIndexPath:indexPath];
}

// boilerplate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:cell.textLabel.text
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
    Chapter *chapter = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([chapter.pagesCount intValue] != [chapter.pages count]
        && ![chapter.downloadStatus isEqualToString:CHAPTER_DOWNLOADING])
    {
        [actionSheet addButtonWithTitle:@"Read and Download"];
    } else {
        [actionSheet addButtonWithTitle:@"Read"];
    }
    
    if (![chapter.downloadStatus isEqualToString:CHAPTER_DOWNLOADED]
        && ![chapter.downloadStatus isEqualToString:CHAPTER_DOWNLOADING])
    {
        [actionSheet addButtonWithTitle:@"Download"];
    }
    
    if ([chapter.downloadStatus isEqualToString:CHAPTER_DOWNLOADING]) {
        [actionSheet addButtonWithTitle:@"Stop downloading"];
    }
    
    if ([chapter.bookmark boolValue] == NO) {
        [actionSheet addButtonWithTitle:@"Bookmark"];
    } else {
        [actionSheet addButtonWithTitle:@"Remove Bookmark"];
    }
    [actionSheet addButtonWithTitle:@"Cancel"]; // put at bottom (don't do at all on iPad)
    
    [actionSheet showInView:self.view]; // different on iPad
}

#pragma mark - Download Tasks

- (void)startDownloadingChapter:(Chapter *)chapter
{
    // If the chapter has been downloading half way
    // continue from the last downloaded page
    NSURL *url;
    if ([chapter.pages count]) {
        NSInteger lastPageIdx = [chapter.pages count] - 1;
        Page *lastDownloadedPage = [Page pageOfChapter:chapter atIndex:lastPageIdx];
        url = [NSURL URLWithString:lastDownloadedPage.url];
    } else {
        url = [NSURL URLWithString:chapter.url];
    }
    
    chapter.downloadStatus = CHAPTER_DOWNLOADING;
    [self downloadHtmlPage:url forChapter:chapter];
}

- (void)stopDownloadingChapter:(Chapter *)chapter
{
    if ([chapter.downloadStatus isEqualToString:CHAPTER_DOWNLOADING]) {
        chapter.downloadStatus = CHAPTER_STOPPED_DOWNLOADING;
        [(MangaBoxAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
    }
}



#pragma mark - Download Tasks

- (void)downloadHtmlPage:(NSURL *)pageHtmlURL forChapter:(Chapter *)chapter
{
    if ([chapter.downloadStatus isEqualToString:CHAPTER_DOWNLOADING]) {
        NSURLRequest *request = [NSURLRequest requestWithURL:pageHtmlURL];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        
        __weak ChaptersCDTVC *weakSelf = self;
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
        //NSURLSessionDownloadTask *task = [self.chapterDownloadSession downloadTaskWithRequest:request
            completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error) {
                if (!error) {
                    NSString *urlString = [request.URL absoluteString];
                    NSData *htmlData = [NSData dataWithContentsOfURL:localfile];
                    
                    // Fetch info according to the source and parse to temporary variable
                    NSDictionary *pageDictionary;
                    if ([urlString rangeOfString:@"mangafox.me"].location != NSNotFound) {
                        pageDictionary = [MangafoxFetcher parseChapterPage:htmlData ofURLString:chapter.url];
                    } else if ([urlString rangeOfString:@"mangareader.net"].location != NSNotFound) {
                        pageDictionary = [MangareaderFetcher parseChapterPage:htmlData ofURLString:chapter.url];
                    }
                    
                    // Check if the page is downloaded correctly
                    if ([chapter.pagesCount intValue] != [chapter.pages count]
                        && ![pageDictionary objectForKey:PAGE_IMAGE_URL])
                    {
                        [weakSelf alert:DOWNLOAD_ERROR];
                        chapter.downloadStatus = CHAPTER_STOPPED_DOWNLOADING;
                        return;
                    }
                    
                    
                    // Set the pagesCount in chapter if it is not already set
                    if (![chapter.pagesCount intValue] && [pageDictionary objectForKey:PAGES_COUNT]) {
                        chapter.pagesCount = [NSNumber numberWithInt:[[pageDictionary objectForKey:PAGES_COUNT] intValue]];
                        [(MangaBoxAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
                    }
                    
                    NSLog(@"%@", pageDictionary);
                    NSLog(@"%lu", (unsigned long)[chapter.pages count]);
                    // start download the image if applicable
                    if ([pageDictionary objectForKey:PAGE_IMAGE_URL]) {
                        [weakSelf downloadPageImageWithPageHtmlDictionary:pageDictionary
                                                        ofPageHtmlURL:request.URL
                                                           forChapter:chapter];
                    }
                } else {
                    NSLog(@"Download Error");
                    [weakSelf alert:DOWNLOAD_ERROR];
                    chapter.downloadStatus = CHAPTER_STOPPED_DOWNLOADING;
                    [(MangaBoxAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
                }
                [session invalidateAndCancel];
            }];
        [task resume];
    }
}

- (void)downloadPageImageWithPageHtmlDictionary:(NSDictionary *)pageHtmlDictionary
                                  ofPageHtmlURL:(NSURL *)pageHtmlURL
                                     forChapter:(Chapter *)chapter
{
    NSURL *imageURL = [NSURL URLWithString:[pageHtmlDictionary objectForKeyedSubscript:PAGE_IMAGE_URL]];
    NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    __weak ChaptersCDTVC *weakSelf = self;
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
    //NSURLSessionDownloadTask *task = [self.chapterDownloadSession downloadTaskWithRequest:request
        completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error) {
            if (!error) {
                NSData *imageData = [NSData dataWithContentsOfURL:localfile];
                if (!imageData) { // if error, update the download status and return
                    //[self errorHandling];
                    [weakSelf alert:DOWNLOAD_ERROR];
                    chapter.downloadStatus = CHAPTER_STOPPED_DOWNLOADING;
                    [(MangaBoxAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
                    return;
                }
                
                UIImage *image = [UIImage imageWithData:imageData];
                NSDictionary *pageDictionary = @{PAGE_URL: [pageHtmlURL absoluteString],
                                                 PAGE_IMAGE_URL: [imageURL absoluteString],
                                                 PAGE_IMAGE_DATA: UIImageJPEGRepresentation(image, 1.0)
                                                 };
                
                // save the page into core data
                Page *newPage = [Page pageWithInfo:pageDictionary
                                         ofChapter:chapter
                            inManagedObjectContext:chapter.managedObjectContext];
                
                // update the chapter updated attribute
                newPage.whichChapter.updated = [NSDate date];
                
                // if all the pages of the chapter is downloaded, reset the downloadStatus
                // and post a notification
                if ([chapter.pagesCount intValue] == [chapter.pages count]) {
                    NSLog(@"Done");
                    chapter.downloadStatus = CHAPTER_DOWNLOADED;
                    
                    // Create notification for finishing download chapter
                    NSDictionary *userInfo = @{ MANGA_TITLE: chapter.whichManga.title };
                    [[NSNotificationCenter defaultCenter] postNotificationName:finishDownloadChapter
                                                                        object:weakSelf
                                                                      userInfo:userInfo];
                }
                [(MangaBoxAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
                
                // Download the next HTML page if applicable
                if ([pageHtmlDictionary objectForKey:NEXT_PAGE_TO_PARSE]) {
                    [weakSelf downloadHtmlPage:[NSURL URLWithString:[pageHtmlDictionary objectForKey:NEXT_PAGE_TO_PARSE]]
                                forChapter:chapter];
                }
            } else {
                // error
                NSLog(@"Download Error");
                [weakSelf alert:DOWNLOAD_ERROR];
                chapter.downloadStatus = CHAPTER_STOPPED_DOWNLOADING;
                [(MangaBoxAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
            }
            [session invalidateAndCancel];
        }];
    [task resume];
}

@end
