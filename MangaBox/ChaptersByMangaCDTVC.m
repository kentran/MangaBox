//
//  ChapterListCDTVC.m
//  MangaBox
//
//  Created by Ken Tran on 11/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "ChaptersByMangaCDTVC.h"
#import "MangaBoxNotification.h"
#import "Manga+Download.h"
#import "Manga+Clear.h"
#import "CoverImage.h"
#import "MangaDictionaryDefinition.h"

@interface ChaptersByMangaCDTVC () <UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistTextLabel;

@property (nonatomic, strong) NSString *downloadButtonTitle;
@end

@implementation ChaptersByMangaCDTVC

- (void)viewDidLoad
{
    self.coverImageView.image = [UIImage imageWithData:self.manga.cover.imageData];
    self.titleTextLabel.text = self.manga.title;
    self.authorTextLabel.text = self.manga.author;
    self.artistTextLabel.text = self.manga.artist;
    
    self.downloadButtonTitle = @"Download all chapters";
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(prepareForAlert:)
                                                 name:errorDownloadingChapter
                                               object:nil];
}

- (void)setManga:(Manga *)manga
{
    _manga = manga;
    self.title = manga.title;
    [self setupFetchedResultsController];
}

- (void)setupFetchedResultsController
{
    NSManagedObjectContext *context = self.manga.managedObjectContext;
    
    if (context) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Chapter"];
        request.predicate = [NSPredicate predicateWithFormat:@"whichManga = %@", self.manga];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"url"
                                                                  ascending:YES
                                                                   selector:@selector(localizedStandardCompare:)]];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:context
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}

#pragma mark - UIActionSheet

- (IBAction)actionButtonTouch:(UIBarButtonItem *)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:self.manga.title
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:self.downloadButtonTitle, @"Update chapter list", @"Remove all downloaded pages", nil];
    
    actionSheet.destructiveButtonIndex = 2;
    [actionSheet showFromBarButtonItem:sender animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [super actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
    NSString *choice = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([choice isEqualToString:@"Download all chapters"]) {
        self.downloadButtonTitle = @"Stop downloading";
        [self.manga startDownloadingAllChapters];
    } else if ([choice isEqualToString:@"Stop downloading"]) {
        self.downloadButtonTitle = @"Download all chapters";
        [self.manga stopDownloadingAllChapters];
    } else if ([choice isEqualToString:@"Remove all downloaded pages"]) {
        [self.manga clearAllPages];
    }
}


@end
