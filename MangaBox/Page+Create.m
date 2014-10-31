//
//  Page+Create.m
//  MangaBox
//
//  Created by Ken Tran on 12/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "Page+Create.h"

@implementation Page (Create)

+ (Page *)pageWithInfo:(NSDictionary *)pageDictionary
             ofChapter:(Chapter *)chapter
inManagedObjectContext:(NSManagedObjectContext *)context
{
    Page *page = nil;
    
    // Check if page exist
#if DEBUG
    NSLog(@"Checking existed page for chapter: %@", chapter.name);
#endif
    for (Page *existedPage in [chapter.pages allObjects]) {
        if ([existedPage.url isEqualToString:[pageDictionary objectForKey:PAGE_URL]]) {
            // Page exist, return it
#if DEBUG
            NSLog(@"Page existed for chapter: %@", chapter.name);
#endif
            return existedPage;
        }
    }
    
    // Page not exist, create it and add to core data
#if DEBUG
    NSLog(@"Inserting new page for chapter: %@", chapter.name);
#endif
    page = [NSEntityDescription insertNewObjectForEntityForName:@"Page"
                                         inManagedObjectContext:context];
    
#if DEBUG
    NSLog(@"Finish inserting new page for chapter: %@", chapter.name);
#endif
    page.url = (NSString *)[pageDictionary objectForKey:PAGE_URL];
    
    /* save image to disk */
    UIImage *image = [UIImage imageWithData:[pageDictionary objectForKey:PAGE_IMAGE_DATA]];
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
    NSURL *imageURL = [self uniqueDocumentURLForChapter:chapter];
    page.imageURL = [imageURL absoluteString];
    [imageData writeToURL:imageURL atomically:YES];

#if DEBUG
    NSLog(@"Finish adding new page params for chapter: %@", chapter.name);
#endif
    page.whichChapter = chapter;
#if DEBUG
    NSLog(@"Finish linking new page chapter: %@", chapter.name);
#endif
    
    return page;
}

+ (NSURL *)uniqueDocumentURLForChapter:(Chapter *)chapter
{
    NSArray *documentDirectories = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSString *chapterName = [[chapter.name  componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]] componentsJoinedByString:@"_"];
    NSString *unique = [NSString stringWithFormat:@"%@_%.0f_%u", chapterName, floor([NSDate timeIntervalSinceReferenceDate]), arc4random()];
    return [[documentDirectories firstObject] URLByAppendingPathComponent:unique];
}

@end
