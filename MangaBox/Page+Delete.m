//
//  Page+Delete.m
//  MangaBox
//
//  Created by Ken Tran on 23/6/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "Page+Delete.h"

@implementation Page (Delete)

- (void)prepareForDeletion
{
    // Remove the file at the path specified in imageURL attribute of the page
    NSURL *imageURL = [NSURL URLWithString:self.imageURL];
    [[NSFileManager defaultManager] removeItemAtURL:imageURL error:NULL];
}

@end
