//
//  Chapter.h
//  MangaBox
//
//  Created by Ken Tran on 20/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Manga, Page;

@interface Chapter : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * pagesCount;
@property (nonatomic, retain) NSSet *pages;
@property (nonatomic, retain) Manga *whichManga;
@end

@interface Chapter (CoreDataGeneratedAccessors)

- (void)addPagesObject:(Page *)value;
- (void)removePagesObject:(Page *)value;
- (void)addPages:(NSSet *)values;
- (void)removePages:(NSSet *)values;

@end
