//
//  CoverImage+Create.h
//  MangaBox
//
//  Created by Ken Tran on 8/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "CoverImage.h"

@interface CoverImage (Create)

+ (CoverImage *)coverWithData:(NSData *)coverData
       inManagedObjectContext:(NSManagedObjectContext *)context;

@end
