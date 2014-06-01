//
//  CoverImage.h
//  MangaBox
//
//  Created by Ken Tran on 1/6/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Manga;

@interface CoverImage : NSManagedObject

@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) Manga *whichManga;

@end
