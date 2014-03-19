//
//  ChaptersCDTVC.m
//  MangaBox
//
//  Created by Ken Tran on 11/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "ChaptersCDTVC.h"
#import "Chapter.h"
#import "Chapter+Download.h"
#import "Manga.h"
#import "CoverImage.h"
#import "ImageViewController.h"
#import "ChapterPageViewController.h"

@interface ChaptersCDTVC() <UIActionSheetDelegate>

@end

@implementation ChaptersCDTVC

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Chapter Cell"];
    
    Chapter *chapter = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = chapter.name;
    
    if (![chapter.pages count]) {
        cell.detailTextLabel.text = @"Please download";
    } else if ([chapter.pagesCount intValue] == [chapter.pages count]) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d/%@ Downloaded", [chapter.pages count], chapter.pagesCount];
    }
    
    return cell;
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
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"View", @"Download", nil];
    

    //[actionSheet addButtonWithTitle:@"Cancel"]; // put at bottom (don't do at all on iPad)
    
    [actionSheet showInView:self.view]; // different on iPad
    
    id detailvc = [self.splitViewController.viewControllers lastObject];
    if ([detailvc isKindOfClass:[UINavigationController class]]) {
        detailvc = [((UINavigationController *)detailvc).viewControllers firstObject];
        [self prepareViewController:detailvc
                           forSegue:nil
                      fromIndexPath:indexPath];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *choice = [actionSheet buttonTitleAtIndex:buttonIndex];
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    Chapter *chapter = [self.fetchedResultsController objectAtIndexPath:indexPath];

    //NSLog(@"%d", [chapter.pages count]);
    if ([choice isEqualToString:@"Download"]) {
        [Chapter startDownloadingChapterPages:chapter];
    } else if ([choice isEqualToString:@"View"]) {
        id detailvc = [self.splitViewController.viewControllers lastObject];
        if ([detailvc isKindOfClass:[UINavigationController class]]) {
            detailvc = [((UINavigationController *)detailvc).viewControllers firstObject];
            [self prepareViewController:detailvc
                               forSegue:nil
                          fromIndexPath:indexPath];
        }
        [self performSegueWithIdentifier:@"Show Pages" sender:actionSheet];
    }
}

@end
