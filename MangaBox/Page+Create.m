//
//  Page+Create.m
//  MangaBox
//
//  Created by Ken Tran on 12/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "Page+Create.h"
#import "MangaDictionaryDefinition.h"

@implementation Page (Create)

+ (Page *)pageWithInfo:(NSDictionary *)pageDictionary
             ofChapter:(Chapter *)chapter
inManagedObjectContext:(NSManagedObjectContext *)context
{
    Page *page = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Page"];
    request.predicate = [NSPredicate predicateWithFormat:@"url = %@", [pageDictionary objectForKey:@"url"]];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        // handle error
    } else if ([matches count]) {
        page = [matches firstObject];
    } else {
        page = [NSEntityDescription insertNewObjectForEntityForName:@"Page"
                                             inManagedObjectContext:context];
        
        page.url = [pageDictionary objectForKey:PAGE_URL];
        page.imageURL = [pageDictionary objectForKey:PAGE_IMAGE_URL];
        page.imageData = [pageDictionary objectForKey:PAGE_IMAGE_DATA];
        page.whichChapter = chapter;
    }
    [page.managedObjectContext save:NULL];
    
    return page;
}

@end
