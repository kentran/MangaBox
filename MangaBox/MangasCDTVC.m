//
//  MangaCDTVC.m
//  MangaBox
//
//  Created by Ken Tran on 9/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "MangasCDTVC.h"
#import "Manga+Create.h"
#import "Chapter+Create.h"
#import "MangaDictionaryDefinition.h"
#import "MangafoxFetcher.h"
#import "ChaptersByMangaCDTVC.h"
#import "CoverImage.h"
#import "UIImage+Thumbnail.h"
#import "MangaBoxAppDelegate.h"

@interface MangasCDTVC () <UIAlertViewDelegate>

@property (nonatomic, strong) NSIndexPath *indexPathForDeletedManga;

@end

@implementation MangasCDTVC

#pragma mark - Properties

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Manga"];
    request.predicate = nil;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"created"
                                                              ascending:NO
                                                               selector:@selector(compare:)]];
    

    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

#pragma mark - UITableViewDataSource

#define TITLE_LABEL_TAG 1
#define CHAPTERS_LABEL_TAG 2
#define COVER_IMAGE_TAG 3
#define SOURCE_IMAGE_TAG 4
#define STATUS_LABEL_TAG 5

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Manga Collection Cell"];
    
    Manga *manga = [self.fetchedResultsController objectAtIndexPath:indexPath];

    UILabel *title = (UILabel *)[cell.contentView viewWithTag:TITLE_LABEL_TAG];
    UILabel *chapters = (UILabel *)[cell.contentView viewWithTag:CHAPTERS_LABEL_TAG];
    UILabel *status = (UILabel *)[cell.contentView viewWithTag:STATUS_LABEL_TAG];
    
    UIImageView *coverImageView = (UIImageView *)[cell.contentView viewWithTag:COVER_IMAGE_TAG];
    UIImageView *sourceImageView = (UIImageView *)[cell.contentView viewWithTag:SOURCE_IMAGE_TAG];
    
    title.text = manga.title;
    title.lineBreakMode = NSLineBreakByWordWrapping;
    title.numberOfLines = 2;
    
    chapters.text = [NSString stringWithFormat:@"%d chapters", [manga.chapters count]];
    
    status.text = manga.completionStatus;
    
    coverImageView.image = [UIImage imageWithData:manga.cover.imageData];
    coverImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    UIImage *logo;
    if ([manga.source isEqualToString:@"mangafox.me"]) {
        logo = [UIImage imageNamed:@"MangafoxLogo"];
    }
    sourceImageView.image = logo;
    sourceImageView.contentMode = UIViewContentModeLeft;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        self.indexPathForDeletedManga = indexPath;
        [self alert:@"This action will also delete all the data related to this manga"];
    }
}

- (void)deleteMangaAtIndexPath:(NSIndexPath *)indexPath
{
    Manga *deletedManga = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.managedObjectContext deleteObject:deletedManga];
    [(MangaBoxAppDelegate*)[[UIApplication sharedApplication] delegate] saveContext];
}

#pragma mark - Alerts

- (void)alert:(NSString *)msg
{
    [[[UIAlertView alloc] initWithTitle:@"Warning"
                                message:msg
                               delegate:self
                      cancelButtonTitle:@"Cancel"
                      otherButtonTitles:@"OK", nil] show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"OK"]
        && [alertView.title isEqualToString:@"Warning"])
    {
        [self deleteMangaAtIndexPath:self.indexPathForDeletedManga];
    }
}

#pragma mark - Navigation

- (void)prepareViewController:(id)vc forSegue:(NSString *)segueIdentifer fromIndexPath:(NSIndexPath *)indexPath
{
    Manga *manga = [self.fetchedResultsController objectAtIndexPath:indexPath];
    // note that we don't check the segue identifier here
    // probably fine ... hard to imagine any other way this class would segue to PhotosByPhotographerCDTVC
    if ([vc isKindOfClass:[ChaptersByMangaCDTVC class]]) {
        ChaptersByMangaCDTVC *clbmcdtvc = (ChaptersByMangaCDTVC *)vc;
        clbmcdtvc.title = manga.title;
        clbmcdtvc.manga = manga;
    }
}

// boilerplate
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = nil;
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        indexPath = [self.tableView indexPathForCell:sender];
    }
    [self prepareViewController:segue.destinationViewController
                       forSegue:segue.identifier
                  fromIndexPath:indexPath];
}

// boilerplate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id detailvc = [self.splitViewController.viewControllers lastObject];
    if ([detailvc isKindOfClass:[UINavigationController class]]) {
        detailvc = [((UINavigationController *)detailvc).viewControllers firstObject];
        [self prepareViewController:detailvc
                           forSegue:nil
                      fromIndexPath:indexPath];
    }
}

@end