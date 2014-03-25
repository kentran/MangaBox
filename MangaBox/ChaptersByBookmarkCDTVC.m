//
//  ChaptersByBookmarkCDTVC.m
//  MangaBox
//
//  Created by Ken Tran on 22/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "ChaptersByBookmarkCDTVC.h"
#import "MangaBoxNotification.h"

@interface ChaptersByBookmarkCDTVC ()

@end

@implementation ChaptersByBookmarkCDTVC

- (void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(prepareForAlert:)
                                                 name:errorDownloadingChapter
                                               object:nil];
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
        
        NSSortDescriptor *urlSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"url"
                                                                            ascending:YES
                                                                             selector:@selector(localizedStandardCompare:)];
        
        request.sortDescriptors = @[urlSortDescriptor];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:context
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}

@end
