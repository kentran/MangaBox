//
//  MangareaderFetcher.m
//  MangaBox
//
//  Created by Ken Tran on 23/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "MangareaderFetcher.h"
#import "TFHpple.h"

@implementation MangareaderFetcher

+ (NSDictionary *)parseMangaDetails:(NSData *)htmlData
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    TFHpple *doc = [[TFHpple alloc] initWithHTMLData:htmlData];
    
    /* Read title */
    NSArray *titleNodes = [doc searchWithXPathQuery:@"//h2[@class='aname']"];
    if ([titleNodes count] && [titleNodes[0] text])
        [result setObject:[titleNodes[0] text] forKey:MANGA_TITLE];
    
    /* Read the author, artist, genres, status, coverURL */
    NSArray *tableRowNodes = [doc searchWithXPathQuery:@"//div[@id='mangaproperties']/table/tr"];
    
    if ([tableRowNodes count] < 6) {
        // Error parsing
        return nil;
    }
    
    /* Completion Status */
    NSArray *statusCells = [tableRowNodes[3] childrenWithTagName:@"td"];
    if ([statusCells count] > 1 && [[statusCells[0] text] rangeOfString:@"Status"].location != NSNotFound) {
        [result setObject:[statusCells[1] text] forKey:MANGA_COMPLETION_STATUS];
    }
    
    /* Author */
    NSArray *authorCells = [tableRowNodes[4] childrenWithTagName:@"td"];
    if ([authorCells count] > 1 && [[authorCells[0] text] rangeOfString:@"Author"].location != NSNotFound) {
        [result setObject:[authorCells[1] text] forKey:MANGA_AUTHOR];
    }
    
    /* Artist */
    NSArray *artistCells = [tableRowNodes[5] childrenWithTagName:@"td"];
    if ([artistCells count] > 1 && [[artistCells[0] text] rangeOfString:@"Artist"].location != NSNotFound) {
        if ([artistCells[1] text])
            [result setObject:[artistCells[1] text] forKey:MANGA_ARTIST];
    }
    
    /* Genres */
    NSArray *genreNodes = [doc searchWithXPathQuery:@"//span[@class='genretags']"];
    if ([genreNodes count]) {
        NSMutableArray *genresArray = [[NSMutableArray alloc] init];
        for (TFHppleElement *aNode in genreNodes) {
            [genresArray addObject:[aNode text]];
        }
        [result setObject:[genresArray componentsJoinedByString:@", "] forKey:MANGA_GENRES];
    }
    
    /* cover URL */
    NSArray *imgNodes = [doc searchWithXPathQuery:@"//div[@id='mangaimg']/img"];
    if ([imgNodes count] && [imgNodes[0] objectForKey:@"src"]) {
        [result setObject:[imgNodes[0] objectForKey:@"src"] forKey:MANGA_COVER_URL];
    }
    
    [result setObject:@"mangareader.net" forKey:MANGA_SOURCE];
    
    return result;
}

+ (NSArray *)parseChapterList:(NSData *)htmlData
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    TFHpple *doc = [[TFHpple alloc] initWithHTMLData:htmlData];
    NSArray *tableRowNodes = [doc searchWithXPathQuery:@"//table[@id='listing']/tr"];
    
    for (TFHppleElement *row in tableRowNodes) {
        if ([row firstChildWithTagName:@"th"])
            continue;
        
        NSArray *cellNodes = [row childrenWithTagName:@"td"];
        if ([cellNodes count]) {
            TFHppleElement *chapterTitleNodes = [cellNodes[0] firstChildWithTagName:@"a"];
            NSString *chapterURL = [NSString stringWithFormat:@"http://www.mangareader.net%@", [chapterTitleNodes objectForKey:@"href"]];
            NSDictionary *chapterDictionary = @{CHAPTER_NAME: [chapterTitleNodes text],
                                                CHAPTER_URL: chapterURL
                                                };
            [result addObject:chapterDictionary];
        }
    }
    
    return result;
}

+ (NSDictionary *)parseChapterPage:(NSData *)htmlData ofURLString:(NSString *)chapterURL
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    TFHpple *doc = [[TFHpple alloc] initWithHTMLData:htmlData];
    
    NSString *currentChapter = [self getChapterPart:chapterURL];
    
    // Read the page info
    NSArray *aTagNodes = [doc searchWithXPathQuery:@"//div[@id='imgholder']/a"];
    if ([aTagNodes count]) {
        TFHppleElement *imgNode = [aTagNodes[0] firstChildWithTagName:@"img"];
        [result setObject:[imgNode objectForKey:@"src"] forKey:PAGE_IMAGE_URL];
        
        NSString *nextPageRelativeURL = [aTagNodes[0] objectForKey:@"href"];
        if ([nextPageRelativeURL rangeOfString:currentChapter].location != NSNotFound) {
            [result setObject:[NSString stringWithFormat:@"http://www.mangareader.net%@", nextPageRelativeURL] forKey:NEXT_PAGE_TO_PARSE];
        }
    }
    
    // Get the number of pages
    NSArray *optionNodes = [doc searchWithXPathQuery:@"//div[@id='selectpage']/select/option"];
    if ([optionNodes count]) {
        TFHppleElement *lastPageOptionNode = [optionNodes objectAtIndex:([optionNodes count] - 1)];
        [result setObject:[lastPageOptionNode text] forKey:PAGES_COUNT];
    }
    
    return result;
}

+ (NSString *)getChapterPart:(NSString *)chapterURL {
    // Filter the chapter part from the chapter URL
    NSString *chapterPart;
    NSRange range = [chapterURL rangeOfString:@"/" options:NSBackwardsSearch];
    if ([chapterURL rangeOfString:@".htm"].location != [chapterURL length] - 1) {
        chapterPart = [chapterURL substringFromIndex:(range.location+1)];
    }
    
    return chapterPart;
}

@end
