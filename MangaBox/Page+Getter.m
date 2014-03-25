//
//  Page+Getter.m
//  MangaBox
//
//  Created by Ken Tran on 25/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "Page+Getter.h"
#import "MangaDictionaryDefinition.h"

@implementation Page (Getter)


+ (Page *)pageOfChapter:(Chapter *)chapter atIndex:(NSInteger)index
{
    Page *page = nil;
    
    // Get the pages of the chapter
    NSArray *pages = [chapter.pages allObjects];
    NSSortDescriptor *urlSort = [[NSSortDescriptor alloc] initWithKey:PAGE_URL
                                                            ascending:YES
                                                             selector:@selector(localizedStandardCompare:)];
    
    if ([pages count] > 0 && [pages count] >= index) {
        // Get the page to load based on the index
        pages = [pages sortedArrayUsingDescriptors:@[urlSort]];
        page = pages[index];
    }
    
    return page;
}

@end
