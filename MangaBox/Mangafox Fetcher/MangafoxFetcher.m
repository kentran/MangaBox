//
//  MangafoxFetcher.m
//  MangaBox
//
//  Created by Ken Tran on 1/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "MangafoxFetcher.h"
#import "TFHpple.h"
#import "NSString+Helper.h"
#import "MangaDictionaryDefinition.h"

@implementation MangafoxFetcher

+ (NSURL *) urlForFetchingMangas:(NSDictionary *) criteria
{
    NSURL *url = nil;
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@", MANGAFOX_ADVANCED_SEARCH_URL];
    
    // name search
    if ([criteria objectForKey:@"name"]) {
        NSString *value = [criteria objectForKey:@"name"];
        [urlString appendString:[NSString stringWithFormat:@"&name_method=cw&name=%@", [value stringByReplacingOccurrencesOfString:@" " withString:@"+"]]];
    }
    
    // author search
    if ([criteria objectForKey:@"author"]) {
        NSString *value = [criteria objectForKey:@"author"];
        [urlString appendString:[NSString stringWithFormat:@"&author_method=cw&author=%@", [value stringByReplacingOccurrencesOfString:@" " withString:@"+"]]];
    }
    
    // artist search
    if ([criteria objectForKey:@"artist"]) {
        NSString *value = [criteria objectForKey:@"artist"];
        [urlString appendString:[NSString stringWithFormat:@"&artist_method=cw&artist=%@", [value stringByReplacingOccurrencesOfString:@" " withString:@"+"]]];
    }
    
    // genres search
    NSDictionary *genres = [criteria objectForKey:@"genres"];
    for (NSString *key in genres) {
        NSString *value = [genres objectForKey:key];
        [urlString appendString:[NSString stringWithFormat:@"&genres%%5B%@%%5D=%@", [key stringByReplacingOccurrencesOfString:@" " withString:@"+"], [value stringByReplacingOccurrencesOfString:@" " withString:@"+"]]];
    }
    
    // sort by
    if ([criteria objectForKey:@"sortBy"]) {
        NSString *value = [criteria objectForKey:@"sortBy"];
        NSString *sortBy;
        if ([value isEqualToString:@"Name"]) sortBy = @"name";
        else if ([value isEqualToString:@"Views"]) sortBy = @"views";
        else if ([value isEqualToString:@"Chapters"]) sortBy = @"total_chapters";
        else if ([value isEqualToString:@"Latest Update"]) sortBy = @"last_chapter_time";
        [urlString appendString:[NSString stringWithFormat:@"&sort=%@", sortBy]];
    }
    
    // sort order
    if ([criteria objectForKey:@"sortOrder"]) {
        NSString *value = [criteria objectForKey:@"sortOrder"];
        NSString *sortOrder;
        if ([value isEqualToString:@"ASC"]) sortOrder = @"az";
        else if ([value isEqualToString:@"DESC"]) sortOrder = @"za";
        [urlString appendString:[NSString stringWithFormat:@"&order=%@", sortOrder]];
    }
    
    // is completed
    if ([criteria objectForKey:@"isCompleted"]) {
        NSString *value = [criteria objectForKey:@"isCompleted"];
        NSString *isCompleted;
        if ([value isEqualToString:@"Completed"]) isCompleted = @"1";
        else if ([value isEqualToString:@"Ongoing"]) isCompleted = @"0";
        else isCompleted = @"";
        [urlString appendString:[NSString stringWithFormat:@"&is_completed=%@", isCompleted]];
    }
    
    // page
    if ([criteria objectForKey:@"page"]) {
        NSString *value = [criteria objectForKey:@"page"];
        [urlString appendString:[NSString stringWithFormat:@"&page=%@", [value stringByReplacingOccurrencesOfString:@" " withString:@"+"]]];
    }

    url = [NSURL URLWithString:urlString];
    
    return url;
}

+ (NSArray *)parseFetchResult:(NSData *)htmlData
{
    TFHpple *doc = [[TFHpple alloc] initWithHTMLData:htmlData];
    
    NSArray *tableRowNodes = [doc searchWithXPathQuery:@"//table[@id='listing']/tr"];

    if ([tableRowNodes count] == 0)
        return nil;
    
    NSMutableArray *result = [[NSMutableArray alloc] init];

    for (TFHppleElement *tableRowNode in tableRowNodes) {
        if ([tableRowNode firstChildWithTagName:@"th"])
            continue;
        
        NSArray *cellNodes = [tableRowNode childrenWithTagName:@"td"];
        TFHppleElement *titleNode = [cellNodes[0] firstChild];
        
        if ([titleNode objectForKey:@"href"]) {
            NSDictionary *item = @{MANGA_TITLE: [titleNode text],
                                   MANGA_URL: [titleNode objectForKey:@"href"],
                                   MANGA_UNIQUE: [titleNode objectForKey:@"rel"],
                                   MANGA_VIEWS: [cellNodes[2] text],
                                   MANGA_CHAPTERS: [cellNodes[3] text] };
            [result addObject:item];
        }
    }

    return result;
}

+ (BOOL)nextMangaListPageAvailability:(NSData *)htmlData
{
    TFHpple *doc = [[TFHpple alloc] initWithHTMLData:htmlData];
    // Check if there is next page, if a node is found, the button is disabled, there is no next page
    NSArray *nextButtonNodes = [doc searchWithXPathQuery:@"//span[@class='disable']/span[@class='next']"];
    if ([nextButtonNodes count])
        return NO;
    else
        return YES;
}

+ (NSDictionary *)parseMangaDetailSummary:(NSData *)htmlData
{
    NSArray *propertyListResult = [NSJSONSerialization JSONObjectWithData:htmlData
                                                                       options:0
                                                                         error:NULL];
    if ([propertyListResult count]) {
        NSDictionary *result = @{MANGA_TITLE: propertyListResult[0],
                                 MANGA_GENRES: propertyListResult[2],
                                 MANGA_AUTHOR: propertyListResult[3],
                                 MANGA_ARTIST: propertyListResult[4],
                                 MANGA_RATING: propertyListResult[7],
                                 MANGA_RELEASED: propertyListResult[8],
                                 MANGA_SUMMARY: [propertyListResult[9] stringByStrippingHTML],
                                 MANGA_COVER_URL: propertyListResult[10]
                                 };
        return result;
    }
    return nil;
}

+ (NSArray *)parseChapterList:(NSData *)htmlData
{
    TFHpple *doc = [[TFHpple alloc] initWithHTMLData:htmlData];
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSArray *chapterNodes = [doc searchWithXPathQuery:@"//ul[@class='chlist']/li/div"];
    
    for (TFHppleElement *chapterNode in chapterNodes) {
        NSArray *aTags = [chapterNode searchWithXPathQuery:@"//a[@class='tips']"];

        // Sometimes the parsed URL lost the first page (1.html)
        // we need to add it in the URL for consistency
        NSMutableString *chapterURL = [NSMutableString stringWithFormat:@"%@", [aTags[0] objectForKey:@"href"]];

        if ([chapterURL rangeOfString:@".html"].location == NSNotFound)
            [chapterURL appendString:@"1.html"];
        
        NSDictionary *chapterInfo = @{CHAPTER_NAME: [aTags[0] text],
                                     CHAPTER_URL: chapterURL
                                     };
        [result addObject:chapterInfo];
    }
    
    return result;
}

+ (NSDictionary *)parseChapterPage:(NSData *)htmlData ofURLString:(NSString *)chapterURL
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    TFHpple *doc = [[TFHpple alloc] initWithHTMLData:htmlData];
    NSArray *aTagNodes = [doc searchWithXPathQuery:@"//div[@id='viewer']/a"];
    
    // get image url and next html page
    if ([aTagNodes count]) {
        TFHppleElement *imageNode = [aTagNodes[0] firstChild];
        
        [result setObject:[imageNode objectForKey:@"src"] forKey:PAGE_IMAGE_URL]; // image URL
        
        NSString *nextPagePart = [aTagNodes[0] objectForKey:@"href"];
        if ([nextPagePart rangeOfString:@"javascript:"].location == NSNotFound) {
            NSString *nextPageToParse = [self urlForNextPage:chapterURL nextPagePart:nextPagePart];
            [result setObject:nextPageToParse forKey:NEXT_PAGE_TO_PARSE];
        }
    }
    
    // get the number of pages
    NSArray *optionNodes = [doc searchWithXPathQuery:@"//div[@class='l']/select/option"];
    TFHppleElement *lastPageOptionNode = [optionNodes objectAtIndex:([optionNodes count] - 2)];
    [result setObject:[lastPageOptionNode text] forKey:PAGES_COUNT];
    
    return result;
}

+ (NSString *)urlForNextPage:(NSString *)currentPageHtmlURL nextPagePart:(NSString *)pagePart
{
    // Filter the chapter part from the chapter URL
    NSString *chapterPart;
    NSRange range = [currentPageHtmlURL rangeOfString:@"/" options:NSBackwardsSearch];
    if ([currentPageHtmlURL rangeOfString:@".htm"].location != NSNotFound) {
        chapterPart = [currentPageHtmlURL substringToIndex:(range.location+1)];
    }

    return [NSString stringWithFormat:@"%@%@", chapterPart, pagePart];
}

+ (NSDictionary *)parseMangaDetails:(NSData *)htmlData
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    TFHpple *doc = [[TFHpple alloc] initWithHTMLData:htmlData];
    
    /* Read title */
    NSArray *h1Nodes = [doc searchWithXPathQuery:@"//h1"];
    if ([h1Nodes count]) {
        TFHppleElement *titleNode = h1Nodes[0];
        NSString *title;
        if ([[titleNode text] rangeOfString:@" Manga"].location != NSNotFound) {
            NSInteger endIdx = [[titleNode text] rangeOfString:@" Manga"].location;
            title = [[titleNode text] substringToIndex:endIdx];
        } else if ([[titleNode text] rangeOfString:@" Manhwa"].location != NSNotFound) {
            NSInteger endIdx = [[titleNode text] rangeOfString:@" Manhwa"].location;
            title = [[titleNode text] substringToIndex:endIdx];
        } else {
            title = [titleNode text];
        }
        [result setObject:title forKey:MANGA_TITLE];
    }
    
    /* Read Released, Author, Artist, Genres */
    NSArray *tableRowNodes = [doc searchWithXPathQuery:@"//table/tr"];
    for (TFHppleElement *tableRowNode in tableRowNodes) {
        if ([tableRowNode firstChildWithTagName:@"th"])
            continue;
        
        NSArray *cellNodes = [tableRowNode childrenWithTagName:@"td"];
        
        if ([cellNodes count]) {
            [result setValuesForKeysWithDictionary:@{
                                                    MANGA_RELEASED: [self stringFromDetailsTd:cellNodes[0]],
                                                    MANGA_AUTHOR: [self stringFromDetailsTd:cellNodes[1]],
                                                    MANGA_ARTIST: [self stringFromDetailsTd:cellNodes[2]],
                                                    MANGA_GENRES: [self stringFromDetailsTd:cellNodes[3]]
                                                     }];
        }
    }
    
    /* Read cover image URL */
    NSArray *imageNodes = [doc searchWithXPathQuery:@"//div[@class='cover']/img"];
    if ([imageNodes count] && [imageNodes[0] objectForKey:@"src"])
        [result setObject:[imageNodes[0] objectForKey:@"src"] forKey:MANGA_COVER_URL];
    
    /* Read status */
    NSArray *dataNodes = [doc searchWithXPathQuery:@"//div[@class='data']/span"];
    if ([dataNodes count]) {
        NSString *status;
        if ([[dataNodes[0] text] rangeOfString:@"Ongoing"].location != NSNotFound)
            status = @"Ongoing";
        else
            status = @"Completed";
        
        [result setObject:status forKey:MANGA_COMPLETION_STATUS];
    }
    
    /* Add the source of the manga to be mangafox */
    [result setObject:@"mangafox.me" forKey:MANGA_SOURCE];
    
    //NSLog(@"%@", result);
    
    return result;
}

+ (NSString *)stringFromDetailsTd:(TFHppleElement *)td
{
    NSArray *aTags = [td childrenWithTagName:@"a"];
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for (TFHppleElement *element in aTags) {
        [result addObject:[element text]];
    }
    
    return [result componentsJoinedByString:@", "];
}

@end
