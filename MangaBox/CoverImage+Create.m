//
//  CoverImage+Create.m
//  MangaBox
//
//  Created by Ken Tran on 8/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "CoverImage+Create.h"

@implementation CoverImage (Create)

+ (CoverImage *)coverWithData:(NSData *)coverData
       inManagedObjectContext:(NSManagedObjectContext *)context
{
    CoverImage *cover = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CoverImage"];
    request.predicate = [NSPredicate predicateWithFormat:@"imageData = %@", coverData];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        // handle error
    } else if (![matches count]) {
        cover = [NSEntityDescription insertNewObjectForEntityForName:@"CoverImage"
                                                     inManagedObjectContext:context];
        cover.imageData = coverData;
    } else {
        cover = [matches firstObject];
    }
    
    return cover;
}

@end
