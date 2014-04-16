//
//  Chapter+UpdateInfo.m
//  MangaBox
//
//  Created by Ken Tran on 3/4/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "Chapter+UpdateInfo.h"
#import "MangaBoxAppDelegate.h"
#import "MangaDictionaryDefinition.h"

@implementation Chapter (UpdateInfo)

- (void)addBookmark
{
    self.bookmark = [NSNumber numberWithBool:YES];
}

- (void)removeBookmark
{
    self.bookmark = [NSNumber numberWithBool:NO];
}

- (void)updateCurrentPageIndex:(NSInteger)pageIndex
{
    self.currentPageIndex = [NSNumber numberWithInteger:pageIndex];
}

- (void)updateDownloadStatus:(NSString *)downloadStatus
{
    NSLog(@"Updating chapter status: %@ - %@", self.name, downloadStatus);
    self.downloadStatus = downloadStatus;
    [(MangaBoxAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
}

+ (void)refreshDownloadStatusInContext:(NSManagedObjectContext *)context;
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Chapter"];
    request.predicate = [NSPredicate predicateWithFormat:@"downloadStatus = %@", CHAPTER_DOWNLOADING];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"url"
                                                              ascending:YES
                                                               selector:@selector(localizedStandardCompare:)]];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (error) {
        NSLog(@"Error fetching downloading chapter at launch");
    } else {
        for (Chapter *chapter in matches) {
            chapter.downloadStatus = CHAPTER_STOPPED_DOWNLOADING;
        }
        [(MangaBoxAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
    }
}

@end
