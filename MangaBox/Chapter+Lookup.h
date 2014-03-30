//
//  Chapter+Lookup.h
//  MangaBox
//
//  Created by Ken Tran on 28/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "Chapter.h"

@interface Chapter (Lookup)

- (Chapter *)nextChapter;
- (Chapter *)previousChapter;

@end
