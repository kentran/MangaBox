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

@implementation MangafoxFetcher

+ (NSURL *) urlForFetchingMangas:(NSDictionary *) criteria
{
    NSURL *url = nil;
    NSMutableArray *part = [[NSMutableArray alloc] init];
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@", MANGAFOX_ADVANCED_SEARCH_URL];
    
    // name search
    if ([criteria objectForKey:@"name"]) {
        NSString *value = [criteria objectForKey:@"name"];
        [urlString appendString:[NSString stringWithFormat:@"&name_method=bw&name=%@", [value stringByReplacingOccurrencesOfString:@" " withString:@"+"]]];
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
    
    for (id key in criteria) {
        id value = [criteria objectForKey:key];
    
        if ([value isKindOfClass:[NSString class]]) {
            
        } else if ([value isKindOfClass:[NSDictionary class]]) {
            
        }
    }
    
    NSLog(@"%@", urlString);
    url = [NSURL URLWithString:urlString];
    //url = [NSURL URLWithString:@"http://mangafox.me/search.php?name_method=cw&name=&type=&author_method=cw&author=&artist_method=cw&artist=&genres%5BAction%5D=0&genres%5BAdult%5D=0&genres%5BAdventure%5D=0&genres%5BComedy%5D=0&genres%5BDoujinshi%5D=0&genres%5BDrama%5D=0&genres%5BEcchi%5D=0&genres%5BFantasy%5D=0&genres%5BGender+Bender%5D=0&genres%5BHarem%5D=0&genres%5BHistorical%5D=0&genres%5BHorror%5D=0&genres%5BJosei%5D=0&genres%5BMartial+Arts%5D=0&genres%5BMature%5D=0&genres%5BMecha%5D=0&genres%5BMystery%5D=0&genres%5BOne+Shot%5D=0&genres%5BPsychological%5D=0&genres%5BRomance%5D=0&genres%5BSchool+Life%5D=0&genres%5BSci-fi%5D=0&genres%5BSeinen%5D=0&genres%5BShoujo%5D=0&genres%5BShoujo+Ai%5D=0&genres%5BShounen%5D=0&genres%5BShounen+Ai%5D=0&genres%5BSlice+of+Life%5D=0&genres%5BSmut%5D=0&genres%5BSports%5D=0&genres%5BSupernatural%5D=0&genres%5BTragedy%5D=0&genres%5BWebtoons%5D=0&genres%5BYaoi%5D=0&genres%5BYuri%5D=0&released_method=eq&released=&rating_method=eq&rating=&is_completed=1&advopts=1&sort=total_chapters&order=za"];
    return url;
}

+ (NSArray *)parseFetchResult:(NSData *)htmlData
{
    TFHpple *doc = [[TFHpple alloc] initWithHTMLData:htmlData];
    
    NSArray *tableRowNodes = [doc searchWithXPathQuery:@"//table[@id='listing']/tr"];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for (TFHppleElement *tableRowNode in tableRowNodes) {
        if ([tableRowNode firstChildWithTagName:@"th"])
            continue;
        
        NSArray *cellNodes = [tableRowNode childrenWithTagName:@"td"];
        TFHppleElement *titleNode = [cellNodes[0] firstChild];
        
        if ([titleNode objectForKey:@"href"]) {
            NSDictionary *item = @{@"title": [titleNode text],
                                   @"url": [titleNode objectForKey:@"href"],
                                   @"unique": [titleNode objectForKey:@"rel"],
                                   @"views": [cellNodes[2] text],
                                   @"chaptersCount": [cellNodes[3] text] };
            [result addObject:item];
        }
    }
    
    return result;
}

+ (NSDictionary *)parseMangaDetailSummary:(NSData *)htmlData
{
    NSArray *propertyListResult = [NSJSONSerialization JSONObjectWithData:htmlData
                                                                       options:0
                                                                         error:NULL];
    if ([propertyListResult count]) {
        NSDictionary *result = @{@"title": propertyListResult[0],
                                 @"genres": propertyListResult[2],
                                 @"author": propertyListResult[3],
                                 @"artist": propertyListResult[4],
                                 @"rating": propertyListResult[7],
                                 @"released": propertyListResult[8],
                                 @"summary": [propertyListResult[9] stringByStrippingHTML],
                                 @"cover": propertyListResult[10]
                                 };
        return result;
    }
    return nil;
}

+ (NSDictionary *)parseMangaDetail:(NSData *)htmlData
{
    TFHpple *doc = [[TFHpple alloc] initWithHTMLData:htmlData];
    
    NSArray *tableRowNodes = [doc searchWithXPathQuery:@"//table/tr"];
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    NSLog(@"test");
    /* Read Released, Author, Artist, Genres */
    for (TFHppleElement *tableRowNode in tableRowNodes) {
        if ([tableRowNode firstChildWithTagName:@"th"])
            continue;
        
        NSArray *cellNodes = [tableRowNode childrenWithTagName:@"td"];
        
        if ([cellNodes count]) {
            [result setValuesForKeysWithDictionary:@{@"released": [self stringFromDetailsTd:cellNodes[0]],
                                   @"author": [self stringFromDetailsTd:cellNodes[1]],
                                   @"artist": [self stringFromDetailsTd:cellNodes[2]],
                                   @"genres": [self stringFromDetailsTd:cellNodes[3]] }];
        }
    }
    NSLog(@"%@", result);
    
    return result;
}

+ (NSString *)stringFromDetailsTd:(TFHppleElement *)td
{
    NSArray *aTags = [td childrenWithTagName:@"a"];
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for (TFHppleElement *element in aTags) {
        [result addObject:[element text]];
    }
    
    return [result componentsJoinedByString:@","];
}

@end
