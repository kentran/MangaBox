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

@property (nonatomic ,strong) ImageScrollView *scrollView;

@end

@implementation ImageViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"View Manga Page"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

#pragma mark - Properties

- (void)setChapter:(Chapter *)chapter
{
    _chapter = chapter;
    [self loadView];
}

- (ImageScrollView *)scrollView
{
    if (!_scrollView) _scrollView = [[ImageScrollView alloc] init];
    return _scrollView;
}

- (void)loadView
{
    // Prepare the ImageScroll View
    NSInteger blankFlag = 0;
    if (self.pageIndex <= ((int)[self.chapter.pages count] - 1)) {
        [self loadPageToView];
    } else {
        //NSLog(@"BLANK");
        //self.scrollView.image = [UIImage imageNamed:@"blank"];
        blankFlag = 1;
    }
    
//    if (blankFlag) {
//        dispatch_queue_t loadPageQ = dispatch_queue_create("Loading Page", NULL);
//        dispatch_async(loadPageQ, ^{
//            NSLog(@"Wating");
//            while (!(self.pageIndex <= ((int)[self.chapter.pages count] - 1)));
//            NSLog(@"Loading done");
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self loadPageToView];
//                //[self loadView];
//                //self.view = self.scrollView;
//            });
//        });
//    }
}

- (void)loadPageToView
{
    [self.chapter updateCurrentPageIndex:self.pageIndex];
    Page *page = [Page pageOfChapter:self.chapter atIndex:self.pageIndex];
    if (page) {
        NSURL *imageURL = [NSURL URLWithString:page.imageURL];
        self.scrollView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
        self.view = self.scrollView;
    }
}


@end
