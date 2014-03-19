//
//  ChapterListCDTVC.m
//  MangaBox
//
//  Created by Ken Tran on 11/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "ChaptersByMangaCDTVC.h"

@interface ChaptersByMangaCDTVC ()

@end

@implementation ChaptersByMangaCDTVC

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



@end
