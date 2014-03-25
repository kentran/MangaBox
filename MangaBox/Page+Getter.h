//
//  Page+Getter.h
//  MangaBox
//
//  Created by Ken Tran on 25/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "Page.h"
#import "Chapter.h"

@interface Page (Getter)

+ (Page *)pageOfChapter:(Chapter *)chapter atIndex:(NSInteger)index;

@end
