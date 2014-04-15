//
//  Chapter+UpdateInfo.h
//  MangaBox
//
//  Created by Ken Tran on 3/4/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "Chapter.h"

@interface Chapter (UpdateInfo)

- (void)addBookmark;
- (void)removeBookmark;

- (void)updateCurrentPageIndex:(NSInteger)pageIndex;

- (void)updateDownloadStatus:(NSString *)downloadStatus;

// Refresh downloadStatus for all chapter when the app launch
// Set downloadStatus to download stopped if it is downloading
+ (void)refreshDownloadStatusInContext:(NSManagedObjectContext *)context;

@end
