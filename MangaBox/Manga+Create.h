//
//  Manga+Create.h
//  MangaBox
//
//  Created by Ken Tran on 8/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "Manga.h"

@interface Manga (Create)

+ (Manga *)mangaWithInfo:(NSDictionary *)mangaDictionary
  inManagedObjectContext:(NSManagedObjectContext *)context;

@end
