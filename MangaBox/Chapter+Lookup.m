//
//  Chapter+Lookup.m
//  MangaBox
//
//  Created by Ken Tran on 28/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "Chapter+Lookup.h"

@implementation Chapter (Lookup)

- (Chapter *)nextChapter
{
    Chapter *nextChapter = nil;
    NSArray *chapters = [self allChapters];
    
    if ([chapters count]) {
        NSInteger currentIndex = [chapters indexOfObject:self];
        if (currentIndex <= (int)[chapters count] - 2) {
            nextChapter = chapters[currentIndex + 1];
        }
    }
    
    return nextChapter;
}

- (Chapter *)previousChapter
{
    Chapter *previousChapter = nil;
    
    NSArray *chapters = [self allChapters];
    
    if ([chapters count]) {
        NSInteger currentIndex = [chapters indexOfObject:self];
        if (currentIndex > 0) {
            previousChapter = chapters[currentIndex - 1];
        }
    }
    
    return previousChapter;
}

- (NSArray *)allChapters
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Chapter"];
    request.predicate = [NSPredicate predicateWithFormat:@"whichManga = %@", self.whichManga];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"url"
                                                              ascending:YES
                                                               selector:@selector(localizedStandardCompare:)]];
    
    NSError *error;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if (!error) {
        return result;
    } else {
        return nil;
    }
}

+ (Chapter *)lastReadChapterOfManga:(Manga *)manga
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Chapter"];
    request.predicate = [NSPredicate predicateWithFormat:@"whichManga = %@", manga];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"updated"
                                                              ascending:NO
                                                               selector:@selector(compare:)]];
    [request setFetchLimit:1];
    
    NSError *error;
    NSArray *result = [manga.managedObjectContext executeFetchRequest:request error:&error];
    
    if (!error) {
        return [result firstObject];
    } else {
        return nil;
    }
}

@end
