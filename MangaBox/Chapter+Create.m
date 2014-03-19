//
//  Chapter+Create.m
//  MangaBox
//
//  Created by Ken Tran on 10/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "Chapter+Create.h"
#import "MangaDictionaryDefinition.h"
#import "Manga+Create.h"

@implementation Chapter (Create)

+ (Chapter *)chapterWithInfo:(NSDictionary *)chapterDictionary
                     ofManga:(Manga *)manga
      inManagedObjectContext:(NSManagedObjectContext *)context
{
    Chapter *chapter = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Chapter"];
    request.predicate = [NSPredicate predicateWithFormat:@"url = %@", [chapterDictionary objectForKey:@"url"]];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        // handle error
    } else if ([matches count]) {
        chapter = [matches firstObject];
    } else {
        chapter = [self insertChapterWithInfo:chapterDictionary
                                      ofManga:manga
                     intoManagedObjectContext:context];
    }
    
    return chapter;
}

+ (void)loadChaptersFromArray:(NSArray *)chapters
                      ofManga:(Manga *)manga
     intoManagedObjectContext:(NSManagedObjectContext *)context
{
    // Create an array of url for checking against db
    NSMutableArray *urlArray = [[NSMutableArray alloc] init];
    for (NSDictionary *chapterInfo in chapters) {
        [urlArray addObject:[chapterInfo valueForKey:@"url"]];
    }

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Chapter"];
    request.predicate = [NSPredicate predicateWithFormat:@"url IN %@", urlArray];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error) {
        // handle error
    } else {
        // Create an array to filter the list of chapter to add
        // Only add the chapters that are not in the core data
        NSMutableArray *matchedURLs = [[NSMutableArray alloc] init];
        for (Chapter *match in matches) {
            [matchedURLs addObject:match.url];
        }

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (url IN %@)", matchedURLs];
        
        NSArray *filteredChapters = [chapters filteredArrayUsingPredicate:predicate];
        for (NSDictionary *chapterDictionary in filteredChapters) {
            [self insertChapterWithInfo:chapterDictionary
                                ofManga:manga
               intoManagedObjectContext:context];
        }
    }
}

+ (Chapter *)insertChapterWithInfo:(NSDictionary *)chapterDictionary
                         ofManga:(Manga *)manga
        intoManagedObjectContext:context
{
    Chapter *chapter = [NSEntityDescription insertNewObjectForEntityForName:@"Chapter"
                                            inManagedObjectContext:context];
    
    chapter.url = [chapterDictionary objectForKey:CHAPTER_URL];
    chapter.name = [chapterDictionary objectForKey:CHAPTER_NAME];
    
    chapter.whichManga = manga;
    
    return chapter;
}

@end
