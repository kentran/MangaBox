//
//  MangaFetcher.m
//  MangaBox
//
//  Created by Ken Tran on 7/4/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "MangaFetcher.h"
#import "MangafoxFetcher.h"
#import "MangareaderFetcher.h"

@implementation MangaFetcher

+ (NSDictionary *)parseMangaDetails:(NSURL *)mangaURL ofSourceURL:(NSURL *)sourceURL
{
    NSDictionary *mangaInfo = nil;
    NSData *htmlData = [NSData dataWithContentsOfURL:mangaURL];
    if ([[sourceURL absoluteString] rangeOfString:@"mangafox.me"].location != NSNotFound) {
        mangaInfo = [MangafoxFetcher parseMangaDetails:htmlData];
    } else if([[sourceURL absoluteString] rangeOfString:@"mangareader.net"].location != NSNotFound) {
        mangaInfo = [MangareaderFetcher parseMangaDetails:htmlData];
    }
    
    return mangaInfo;
}

+ (NSArray *)parseChapterList:(NSURL *)mangaURL ofSourceURL:(NSURL *)sourceURL
{
    NSArray *chapterList = nil;
    NSData *htmlData = [NSData dataWithContentsOfURL:mangaURL];
    if ([[sourceURL absoluteString] rangeOfString:@"mangafox.me"].location != NSNotFound) {
        chapterList = [MangafoxFetcher parseChapterList:htmlData];
    } else if([[sourceURL absoluteString] rangeOfString:@"mangareader.net"].location != NSNotFound) {
        chapterList = [MangareaderFetcher parseChapterList:htmlData];
    }
    
    return chapterList;
}

+ (NSDictionary *)parseChapterPage:(NSURL *)pageHtmlURL ofChapterURLString:(NSString *)chapterURLString
{
    NSDictionary *pageDictionary = nil;
    NSData *htmlData = [NSData dataWithContentsOfURL:pageHtmlURL];
    if ([chapterURLString rangeOfString:@"mangafox.me"].location != NSNotFound) {
        pageDictionary = [MangafoxFetcher parseChapterPage:htmlData ofURLString:chapterURLString];
    } else if ([chapterURLString rangeOfString:@"mangareader.net"].location != NSNotFound) {
        pageDictionary = [MangareaderFetcher parseChapterPage:htmlData ofURLString:chapterURLString];
    }
    
    return pageDictionary;
}

+ (UIImage *)logoForSource:(NSString *)source
{
    if ([source isEqualToString:@"mangafox.me"]) {
        return [UIImage imageNamed:@"MangafoxLogo"];
    } else if ([source isEqualToString:@"mangareader.net"]) {
        return [UIImage imageNamed:@"MangareaderLogo"];
    } else {
        return [UIImage imageNamed:@"blank"];
    }
}

@end
