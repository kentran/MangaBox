//
//  Manga+Clear.m
//  MangaBox
//
//  Created by Ken Tran on 25/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "Manga+Clear.h"
#import "Chapter.h"
#import "Page.h"

@implementation Manga (Clear)

- (void)clearAllPages
{
    NSArray *chapters = [self.chapters allObjects];
    for (Chapter *chapter in chapters) {
        if (chapter.pagesCount) {
            for (Page *page in [chapter.pages allObjects]) {
                [chapter.managedObjectContext deleteObject:page];
            }
            chapter.downloadStatus = CHAPTER_CLEARED;
        }
    }
}

@end
