//
//  Manga+Clear.m
//  MangaBox
//
//  Created by Ken Tran on 25/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "Manga+Clear.h"
#import "Chapter.h"
#import "MangaDictionaryDefinition.h"
#import "MangaBoxAppDelegate.h"

@implementation Manga (Clear)

- (void)clearAllPages
{
    NSArray *chapters = [self.chapters allObjects];
    for (Chapter *chapter in chapters) {
        if (chapter.pagesCount) {
            [chapter removePages:chapter.pages];
            chapter.downloadStatus = CHAPTER_CLEARED;
        }
    }
    [(MangaBoxAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
}

@end
