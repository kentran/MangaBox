//
//  Chapter.h
//  MangaBox
//
//  Created by Ken Tran on 22/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Manga, Page;

@interface Chapter : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * pagesCount;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * downloadStatus;
@property (nonatomic, retain) NSDate * updated;
@property (nonatomic, retain) NSNumber * currentPageIndex;
@property (nonatomic, retain) NSNumber * bookmark;
@property (nonatomic, retain) NSSet *pages;
@property (nonatomic, retain) Manga *whichManga;
@end

@interface Chapter (CoreDataGeneratedAccessors)

- (void)addPagesObject:(Page *)value;
- (void)removePagesObject:(Page *)value;
- (void)addPages:(NSSet *)values;
- (void)removePages:(NSSet *)values;

@end
