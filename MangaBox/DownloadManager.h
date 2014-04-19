//
//  DownloadManager.h
//  MangaBox
//
//  Created by Ken Tran on 8/4/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Chapter.h"
#import "Manga.h"

@interface DownloadManager : NSObject

+ (id)sharedManager;

@property (nonatomic, strong) NSMutableArray *downloadingChapters;
@property (nonatomic, strong) NSMutableArray *queueingChapters;

- (void)startDownloadingChapter:(Chapter *)chapter;
- (void)stopDownloadingChapter:(Chapter *)chapter;

- (void)enqueueChapters:(NSArray *)chapters;
- (void)stopAllDownloadingForManga:(Manga *)manga;

- (void)updateChapterListForManga:(Manga *)manga;
@end
