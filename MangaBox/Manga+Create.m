//
//  Manga+Create.m
//  MangaBox
//
//  Created by Ken Tran on 8/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "Manga+Create.h"
#import "CoverImage+Create.h"
#import "MangaDictionaryDefinition.h"

@implementation Manga (Create)

+ (Manga *)mangaWithInfo:(NSDictionary *)mangaDictionary
  inManagedObjectContext:(NSManagedObjectContext *)context
{
    Manga *manga = nil;
    
    NSString *url = mangaDictionary[MANGA_URL];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Manga"];
    request.predicate = [NSPredicate predicateWithFormat:@"url = %@", url];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || [matches count] > 1)
    {
        //handle error
        
    } else if ([matches count] == 1) {
        return [matches firstObject];
    } else {
        if ([mangaDictionary[@"title"] length]) {
            manga = [NSEntityDescription insertNewObjectForEntityForName:@"Manga"
                                                  inManagedObjectContext:context];
            
            manga.title = [mangaDictionary valueForKeyPath:MANGA_TITLE];
            manga.url = [mangaDictionary valueForKeyPath:MANGA_URL];
            manga.author = [mangaDictionary valueForKeyPath:MANGA_AUTHOR];
            manga.artist = [mangaDictionary valueForKeyPath:MANGA_ARTIST];
            manga.genres = [mangaDictionary valueForKeyPath:MANGA_GENRES];
            manga.source = [mangaDictionary valueForKeyPath:MANGA_SOURCE];
            manga.completionStatus = [mangaDictionary valueForKeyPath:MANGA_COMPLETION_STATUS];
            manga.created = [NSDate date];
            
            NSData *coverData = [mangaDictionary valueForKeyPath:MANGA_COVER_DATA];
            manga.cover = [CoverImage coverWithData:coverData
                             inManagedObjectContext:context];
        }
    }
    
    return manga;
}

@end
