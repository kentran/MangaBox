//
//  Chapter+Create.h
//  MangaBox
//
//  Created by Ken Tran on 10/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "Chapter.h"
#import "Manga.h"

@interface Chapter (Create)
+ (Chapter *)chapterWithInfo:(NSDictionary *)chapterDictionary
                     ofManga:(Manga *)manga
      inManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)loadChaptersFromArray:(NSArray *)chapters
                      ofManga:(Manga *)manga
     intoManagedObjectContext:(NSManagedObjectContext *)context;

@end
