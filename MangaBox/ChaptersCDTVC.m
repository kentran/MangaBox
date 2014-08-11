//
//  ChaptersCDTVC.m
//  MangaBox
//
//  Created by Ken Tran on 11/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "ChaptersCDTVC.h"
#import "Manga.h"
#import "Page+Create.h"
#import "Page+Getter.h"
#import "CoverImage.h"
#import "ImageViewController.h"
#import "ChapterViewController.h"
#import "Chapter+UpdateInfo.h"
#import "MangaFetcher.h"


@interface ChaptersCDTVC() <UIActionSheetDelegate>
// hold the value of the index path selected
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@end

@implementation ChaptersCDTVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.fetchedResultsController.delegate = self;
    [self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.fetchedResultsController.delegate = nil;
}

#pragma mark - Properties

- (DownloadManager *)downloadManager
{
    if (!_downloadManager) _downloadManager = [DownloadManager sharedManager];
    return _downloadManager;
}

- (id<GAITracker>)tracker
{
    return [[GAI sharedInstance] defaultTracker];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Chapter Cell"];
    [self configure:cell atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Chapter *deletedChapter = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [deletedChapter.managedObjectContext deleteObject:deletedChapter];
    }
}

#define TITLE_LABEL_TAG 1
#define PAGES_LABEL_TAG 2
#define PROGRESS_BAR_TAG 3
#define STAR_IMAGE_TAG 4

- (void)configure:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
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
        pages.textColor = UIColorFromRGB(0x88898c);
        progressBar.hidden = YES;
    } else if ([chapter.downloadStatus isEqualToString:CHAPTER_DOWNLOADED]) {
        progressBar.hidden = YES;
        pages.text = [NSString stringWithFormat:@"Pages: %lu/%@", (unsigned long)[chapter.pages count], chapter.pagesCount];
        pages.textColor = UIColorFromRGB(0x648f00);
    } else if ([chapter.downloadStatus isEqualToString:CHAPTER_DOWNLOADING]) {
        pages.text = [NSString stringWithFormat:@"Downloading... %lu/%@", (unsigned long)[chapter.pages count], chapter.pagesCount];
        pages.textColor = UIColorFromRGB(0x648f00);
        
        // Add progress bar for downloading view
        progressBar.hidden = NO;
        if ([chapter.pagesCount doubleValue]) {
            progressBar.progress = [chapter.pages count] / [chapter.pagesCount doubleValue];
        } else {
            progressBar.progress = 0.0;
        }
    } else if ([chapter.downloadStatus isEqualToString:CHAPTER_STOPPED_DOWNLOADING]) {
        progressBar.hidden = YES;
        pages.text = [NSString stringWithFormat:@"Download stopped... %lu/%@", (unsigned long)[chapter.pages count], chapter.pagesCount];
        pages.textColor = UIColorFromRGB(0x88898c);
    } else {
        pages.text = [NSString stringWithFormat:@"Pages: %lu/%@", (unsigned long)[chapter.pages count], chapter.pagesCount];
        pages.textColor = UIColorFromRGB(0x88898c);
        progressBar.hidden = YES;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    CGFloat direction = 1; // from right
//    cell.transform = CGAffineTransformMakeTranslation(direction * cell.bounds.size.width, 0);
//    [UIView animateWithDuration:0.25 animations:^{
//        cell.transform = CGAffineTransformIdentity;
//    }];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"%d", buttonIndex);
    // if tap outside of actionsheet on ipad, actionsheet will automatically cancel
    if (buttonIndex < 0) return;
    
    NSString *choice = [actionSheet buttonTitleAtIndex:buttonIndex];
    NSIndexPath *indexPath = self.selectedIndexPath;
    Chapter *chapter = [self.fetchedResultsController objectAtIndexPath:self.selectedIndexPath];

    if ([choice isEqualToString:@"Download"]) {
        [self.downloadManager startDownloadingChapter:chapter];
    } else if ([choice isEqualToString:@"Read"]) {
        id detailvc = [self.splitViewController.viewControllers lastObject];
        if ([detailvc isKindOfClass:[UINavigationController class]]) {
            detailvc = [((UINavigationController *)detailvc).viewControllers firstObject];
            [self prepareViewController:detailvc
                               forSegue:nil
                          fromIndexPath:indexPath];
        }
        [self performSegueWithIdentifier:@"Show Pages" sender:actionSheet];
    } else if ([choice isEqualToString:@"Read and Download"]) {
        [self.downloadManager startDownloadingChapter:chapter];
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
        [self.downloadManager stopDownloadingChapter:chapter];
    }
    
    // Track the action sheet button
    [self trackEventWithLabel:choice andValue:nil];
}

- (void)trackEventWithLabel:(NSString *)label andValue:(NSNumber *)value
{
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"action_sheet"
                                                               action:@"button_press"
                                                                label:label
                                                                value:value] build]];
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
        indexPath = self.selectedIndexPath;
    } else if ([sender isKindOfClass:[Chapter class]]) {
        indexPath = [self.fetchedResultsController indexPathForObject:sender];
    }
    [self prepareViewController:segue.destinationViewController
                       forSegue:segue.identifier
                  fromIndexPath:indexPath];
}

// boilerplate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndexPath = indexPath;
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:cell.textLabel.text
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
    Chapter *chapter = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (![chapter.downloadStatus isEqualToString:CHAPTER_DOWNLOADED]
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

    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        [actionSheet addButtonWithTitle:@"Cancel"]; // put at bottom (don't do at all on iPad)
    }
    
    [actionSheet showInView:self.view]; // different on iPad
}

@end
