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

@interface ImageViewController () <UIScrollViewDelegate, UIGestureRecognizerDelegate>

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

- (void)setPageIndex:(NSInteger)pageIndex
{
    _pageIndex = pageIndex;
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
    if (self.pageIndex <= ((int)[self.chapter.pages count] - 1)) {
        Page *page = [Page pageOfChapter:self.chapter atIndex:self.pageIndex];
        if (page) {
            NSURL *imageURL = [NSURL URLWithString:page.imageURL];
            self.scrollView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
            self.view = self.scrollView;
            NSLog(@"%@ %d", page.url, self.pageIndex);
        }
    } else {
        self.scrollView.image = [UIImage imageNamed:@"blank"];
        self.view = self.scrollView;
        [self showSpinner];
    }
}

- (void)showSpinner
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:spinner];
    
    // Center the spinner in view
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    if (self.pageSetting == SETTING_1_PAGE) {
        spinner.center = CGPointMake(screenRect.size.width/2, screenRect.size.height/2);
    } else if (self.pageSetting == SETTING_2_PAGES) {
        spinner.center = CGPointMake(screenRect.size.height/4, screenRect.size.width/2);
    }
    
    // Start animating
    [spinner startAnimating];
}

@end
