//
//  MangareaderFetcher.h
//  MangaBox
//
//  Created by Ken Tran on 23/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MangareaderFetcher : NSObject

+ (NSDictionary *)parseMangaDetails:(NSData *)htmlData;
+ (NSArray *)parseChapterList:(NSData *)htmlData;
+ (NSDictionary *)parseChapterPage:(NSData *)htmlData ofURLString:(NSString *)chapterURL;

@end
