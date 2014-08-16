//
//  ChaptersByBookmarkCDTVC.m
//  MangaBox
//
//  Created by Ken Tran on 22/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "ChaptersByBookmarkCDTVC.h"

@interface ChaptersByBookmarkCDTVC ()

@end

@implementation ChaptersByBookmarkCDTVC

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Bookmarks Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupFetchedResultsController];
}

- (void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(prepareForAlert:)
                                                 name:errorDownloadingChapter
                                               object:nil];
    
    self.tableView.sectionIndexBackgroundColor = self.view.backgroundColor;
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    [self setupFetchedResultsController];
}

- (void)setupFetchedResultsController
{
    NSManagedObjectContext *context = self.managedObjectContext;
    
    if (context) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Chapter"];
        request.predicate = [NSPredicate predicateWithFormat:@"bookmark = %@", [NSNumber numberWithBool:YES]];
        
        NSSortDescriptor *mangaSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"whichManga.title"
                                                                              ascending:YES
                                                                               selector:@selector(localizedStandardCompare:)];
        NSSortDescriptor *urlSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"url"
                                                                            ascending:YES
                                                                             selector:@selector(localizedStandardCompare:)];
        
        request.sortDescriptors = @[mangaSortDescriptor, urlSortDescriptor];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:context
                                                                              sectionNameKeyPath:@"whichManga.title"
                                                                                       cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}

@end
