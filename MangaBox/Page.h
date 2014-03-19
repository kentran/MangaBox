//
//  Page.h
//  MangaBox
//
//  Created by Ken Tran on 12/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Chapter;

@interface Page : NSManagedObject

@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) Chapter *whichChapter;

@end
