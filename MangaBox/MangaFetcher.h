//
//  MangaFetcher.h
//  MangaBox
//
//  Created by Ken Tran on 7/4/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MangaFetcher : NSObject

// Provide the NSURL to the local downloaded file to parse info
// Also provide the original url to the source to use the correct fetcher
+ (NSDictionary *)parseMangaDetails:(NSURL *)mangaURL ofSourceURL:(NSURL *)sourceURL;

+ (NSArray *)parseChapterList:(NSURL *)mangaURL ofSourceURL:(NSURL *)sourceURL;

+ (NSDictionary *)parseChapterPage:(NSURL *)pageHtmlURL ofChapterURLString:(NSString *)chapterURLString;

+ (UIImage *)logoForSource:(NSString *)source;

@end
