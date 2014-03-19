//
//  Page+Create.h
//  MangaBox
//
//  Created by Ken Tran on 12/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "Page.h"
#import "Chapter.h"

@interface Page (Create)

+ (Page *)pageWithInfo:(NSDictionary *)pageDictionary
             ofChapter:(Chapter *)chapter
inManagedObjectContext:(NSManagedObjectContext *)context;

@end
