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
#import "ChaptersByMangaCDTVC.h"
#import "CoverImage.h"
#import "UIImage+Thumbnail.h"
#import "MangaBoxAppDelegate.h"
#import "MangaFetcher.h"
#import "MangaViewController.h"

@interface MangasCDTVC () <UIAlertViewDelegate>

@property (nonatomic, strong) NSIndexPath *indexPathForDeletedManga;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (nonatomic, strong) NSString *sortType; // title-asc, title-desc, date
@property (nonatomic, strong) NSString *sortKey; // title, created
@property BOOL sortOrder;

@end

@implementation MangasCDTVC

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Collections Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self.sortType isEqualToString:COLLECTION_SORT_TYPE_TITLE_ASC]) {
        [self.segmentControl setSelectedSegmentIndex:0];
    } else if ([self.sortType isEqualToString:COLLECTION_SORT_TYPE_TITLE_DESC]) {
        [self.segmentControl setSelectedSegmentIndex:1];
    } else if ([self.sortType isEqualToString:COLLECTION_SORT_TYPE_DATE]) {
        [self.segmentControl setSelectedSegmentIndex:2];
    }
}

#pragma mark - Properties

- (NSString *)sortType
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:COLLECTION_SORT_TYPE];
}

- (void)setSortType:(NSString *)sortType
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:sortType forKey:COLLECTION_SORT_TYPE];
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    [self setupFetchResultController];
}

- (void)setupFetchResultController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Manga"];
    request.predicate = nil;
    
    if ([self.sortType isEqualToString:COLLECTION_SORT_TYPE_TITLE_ASC]) {
        self.sortKey = @"title";
        self.sortOrder = YES;
    } else if ([self.sortType isEqualToString:COLLECTION_SORT_TYPE_TITLE_DESC]) {
        self.sortKey = @"title";
        self.sortOrder = NO;
    } else if ([self.sortType isEqualToString:COLLECTION_SORT_TYPE_DATE]) {
        self.sortKey = @"created";
        self.sortOrder = NO;
    }
    
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:(self.sortKey) ? self.sortKey : @"title"
                                                              ascending:self.sortOrder
                                                               selector:@selector(compare:)]];
    
    
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

#pragma mark - IBAction

- (IBAction)sort:(UISegmentedControl *)sender
{
    switch (self.segmentControl.selectedSegmentIndex) {
        case 0:
            self.sortType = COLLECTION_SORT_TYPE_TITLE_ASC;
            break;
        case 1:
            self.sortType = COLLECTION_SORT_TYPE_TITLE_DESC;
            break;
        case 2:
            self.sortType = COLLECTION_SORT_TYPE_DATE;
            break;
        default: break;
    }
    [self setupFetchResultController];
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
    
    title.text = manga.title;
    title.lineBreakMode = NSLineBreakByWordWrapping;
    title.numberOfLines = 2;
    
    chapters.text = [NSString stringWithFormat:@"%lu chapters", (unsigned long)[manga.chapters count]];
    
    status.text = manga.completionStatus;
    
    UIImageView *coverImageView = (UIImageView *)[cell.contentView viewWithTag:COVER_IMAGE_TAG];
    coverImageView.image = [UIImage imageWithData:manga.cover.imageData];
    coverImageView.contentMode = UIViewContentModeScaleToFill;
    
    UIImageView *sourceImageView = (UIImageView *)[cell.contentView viewWithTag:SOURCE_IMAGE_TAG];
    UIImage *logo = [MangaFetcher logoForSource:manga.source];
    sourceImageView.image = logo;
    sourceImageView.contentMode = UIViewContentModeLeft;
    
    cell.backgroundColor = UIColorFromRGB(0x121314);
    
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
        clbmcdtvc.manga = manga;
    } else if ([vc isKindOfClass:[MangaViewController class]]) {
        MangaViewController *mangaVC = (MangaViewController *)vc;
        mangaVC.manga = manga;
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
