//
//  Chapter+UpdateInfo.m
//  MangaBox
//
//  Created by Ken Tran on 3/4/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "Chapter+UpdateInfo.h"
#import "MangaBoxAppDelegate.h"

@implementation Chapter (UpdateInfo)

- (void)addBookmark
{
    self.bookmark = [NSNumber numberWithBool:YES];
    [(MangaBoxAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
}

- (void)removeBookmark
{
    self.bookmark = [NSNumber numberWithBool:NO];
    [(MangaBoxAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
}

@end
