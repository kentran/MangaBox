//
//  Chapter+UpdateInfo.m
//  MangaBox
//
//  Created by Ken Tran on 3/4/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "Chapter+UpdateInfo.h"

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
    self.updated = [NSDate date];
}

- (void)updateDownloadStatus:(NSString *)downloadStatus
{
#ifdef DEBUG
    NSLog(@"Updating chapter status: %@ - %@", self.name, downloadStatus);
#endif
    self.downloadStatus = downloadStatus;
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
#ifdef DEBUG
        NSLog(@"Error fetching downloading chapter at launch");
#endif
    } else {
        for (Chapter *chapter in matches) {
            chapter.downloadStatus = CHAPTER_STOPPED_DOWNLOADING;
        }
    }
}

@end
