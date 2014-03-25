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
#import "CoverImage.h"
#import "ImageViewController.h"
#import "ChapterPageViewController.h"
#import "MangaDictionaryDefinition.h"
#import "MangaBoxNotification.h"

@interface ChaptersCDTVC() <UIActionSheetDelegate>

@end

@implementation ChaptersCDTVC

#pragma mark - UITableViewDataSource

#define TITLE_LABEL_TAG 1
#define PAGES_LABEL_TAG 2
#define PROGRESS_BAR_TAG 3

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Chapter Cell"];
    [self configure:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - NSFetchedResultsControllerDelegate

//- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
//{
//
//}
//
//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
//{
//
//}

//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
//{
////    if (![NSThread isMainThread])
////        NSLog(@"NOT MAIN THREAD");
////    dispatch_async(dispatch_get_main_queue(), ^{
////        //[self.tableView reloadData];
////    });
////    NSLog(@"reload");
//    
//}

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
        
        UIProgressView *progressBar = (UIProgressView *)[cell.contentView viewWithTag:PROGRESS_BAR_TAG];
        
        if (![chapter.pages count] && ![chapter.pagesCount intValue]) {
            pages.text = @"Please download to read";
        } else if ([chapter.downloadStatus isEqualToString:CHAPTER_DOWNLOADED]) {
            progressBar.hidden = YES;
            pages.text = [NSString stringWithFormat:@"Downloaded %lu/%@", (unsigned long)[chapter.pages count], chapter.pagesCount];
        } else if ([chapter.downloadStatus isEqualToString:CHAPTER_DOWNLOADING]) {
            pages.text = [NSString stringWithFormat:@"Downloading... %lu/%@", (unsigned long)[chapter.pages count], chapter.pagesCount];
            
            // Add progress bar for downloading view
            progressBar.hidden = NO;
            progressBar.progress = [chapter.pages count] / [chapter.pagesCount doubleValue];
        } else if ([chapter.downloadStatus isEqualToString:CHAPTER_STOPPED_DOWNLOADING]) {
            progressBar.hidden = YES;
            pages.text = [NSString stringWithFormat:@"Download stopped... %lu/%@", (unsigned long)[chapter.pages count], chapter.pagesCount];
        } else {
            pages.text = [NSString stringWithFormat:@"%lu/%@ Pages", (unsigned long)[chapter.pages count], chapter.pagesCount];
        }
        
    });
}

- (void)configureCellAtIndexPath:(NSIndexPath *)indexPath withObject:(Chapter *)chapter
{
    dispatch_async(dispatch_get_main_queue(), ^{
 
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        UILabel *title, *pages;
        title = (UILabel *)[cell.contentView viewWithTag:TITLE_LABEL_TAG];
        title.text = chapter.name;
        pages = (UILabel *)[cell.contentView viewWithTag:PAGES_LABEL_TAG];
        
        UIProgressView *progressBar = (UIProgressView *)[cell.contentView viewWithTag:PROGRESS_BAR_TAG];
        
        if (![chapter.pages count]) {
            pages.text = @"Please download to view";
        } else if ([chapter.downloadStatus isEqualToString:CHAPTER_DOWNLOADED]) {
            progressBar.hidden = YES;
            pages.text = [NSString stringWithFormat:@"%lu/%@ Downloaded", (unsigned long)[chapter.pages count], chapter.pagesCount];
        } else if ([chapter.downloadStatus isEqualToString:CHAPTER_DOWNLOADING]) {
            pages.text = [NSString stringWithFormat:@"%lu/%@ Downloading", (unsigned long)[chapter.pages count], chapter.pagesCount];
            
            // Add progress bar for downloading view
            progressBar.hidden = NO;
            progressBar.progress = [chapter.pages count] / [chapter.pagesCount doubleValue];
            
            if (progressBar.progress == 1.0) {
                progressBar.hidden = YES;
            }
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
        [chapter startDownloadingChapterPages];
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
        chapter.bookmark = [NSNumber numberWithBool:YES];
        [chapter.managedObjectContext save:NULL];
    } else if ([choice isEqualToString:@"Stop downloading"]) {
        [chapter stopDownloadingChapterPages];
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
    if ([vc isKindOfClass:[ChapterPageViewController class]]) {
        ChapterPageViewController *chapterPVC = (ChapterPageViewController *)vc;
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
    
    [actionSheet addButtonWithTitle:@"Bookmark"];
    [actionSheet addButtonWithTitle:@"Cancel"]; // put at bottom (don't do at all on iPad)
    
    [actionSheet showInView:self.view]; // different on iPad
}

@end
