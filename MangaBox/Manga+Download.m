//
//  Manga+Download.m
//  MangaBox
//
//  Created by Ken Tran on 25/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "Manga+Download.h"
#import "Chapter+Download.h"

@implementation Manga (Download)

- (void)startDownloadingAllChapters
{

}

- (void)stopDownloadingAllChapters
{
    NSArray *chapters = [self.chapters allObjects];
    for (Chapter *chapter in chapters) {
        [chapter stopDownloadingChapterPages];
    }
}

@end
