//
//  ImageViewController.m
//  Imaginarium
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import "ImageViewController.h"
#import "MangaDictionaryDefinition.h"
#import "Page+Getter.h"
#import "ImageScrollView.h"
#import "Chapter+UpdateInfo.h"

@interface ImageViewController () <UIScrollViewDelegate>

@end

@implementation ImageViewController

#pragma mark - Properties

- (void)setChapter:(Chapter *)chapter
{
    _chapter = chapter;
    [self loadView];
}

- (void)loadView
{
    // Prepare the ImageScroll View
    ImageScrollView *scrollView = [[ImageScrollView alloc] init];
    if (self.pageIndex <= [self.chapter.pages count] - 1) {
        Page *page = [Page pageOfChapter:self.chapter atIndex:self.pageIndex];
        if (page)
            scrollView.image = [UIImage imageWithData:page.imageData];
    } else {
        scrollView.image = [UIImage imageNamed:@"blank"];
    }
    
    // Replace the view property with the ImageScrollView
    self.view = scrollView;
}


@end
