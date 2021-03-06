//
//  MangafoxFetcher.h
//  MangaBox
//
//  Created by Ken Tran on 1/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MANGAFOX_AJAX_SEARCH_URL @"http://mangafox.me/ajax/series.php"
#define MANGAFOX_ADVANCED_SEARCH_URL @"http://mangafox.me/search.php?advopts=1"

@interface MangafoxFetcher : NSObject

// Manga Info API
+ (NSDictionary *)parseMangaDetails:(NSData *)htmlData;
+ (NSArray *)parseChapterList:(NSData *)htmlData;
+ (NSDictionary *)parseChapterPage:(NSData *)htmlData ofURLString:(NSString *)chapterURL;

// Advanced Search API
+ (NSURL *)urlForFetchingMangas:(NSDictionary *)criteria;
+ (NSArray *)parseFetchResult:(NSData *)htmlData;
+ (BOOL)nextMangaListPageAvailability:(NSData *)htmlData;
+ (NSDictionary *)parseMangaDetailSummary:(NSData *)htmlData;


@end
