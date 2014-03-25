//
//  Manga.h
//  MangaBox
//
//  Created by Ken Tran on 22/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Chapter, CoverImage;

@interface Manga : NSManagedObject

@property (nonatomic, retain) NSString * artist;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * coverURL;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSString * genres;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * unique;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSString * completionStatus;
@property (nonatomic, retain) NSSet *chapters;
@property (nonatomic, retain) CoverImage *cover;
@end

@interface Manga (CoreDataGeneratedAccessors)

- (void)addChaptersObject:(Chapter *)value;
- (void)removeChaptersObject:(Chapter *)value;
- (void)addChapters:(NSSet *)values;
- (void)removeChapters:(NSSet *)values;

@end
