//
//  ImageViewController.m
//  Imaginarium
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import "ImageViewController.h"
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
        [self.chapter updateCurrentPageIndex:self.pageIndex];
        Page *page = [Page pageOfChapter:self.chapter atIndex:self.pageIndex];
        if (page) {
            NSURL *imageURL = [NSURL URLWithString:page.imageURL];
            scrollView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
        }
    } else {
        scrollView.image = [UIImage imageNamed:@"blank"];
    }
    
    // Replace the view property with the ImageScrollView
    self.view = scrollView;
}


@end
