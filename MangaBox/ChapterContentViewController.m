//
//  ChapterContentViewController.m
//  MangaBox
//
//  Created by Ken Tran on 4/8/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "ChapterContentViewController.h"
#import "ImageViewController.h"

@interface ChapterContentViewController () <UIGestureRecognizerDelegate>

@property (nonatomic) NSInteger childViewsCount;

@property (nonatomic, strong) UIView *previousTapArea;
@property (nonatomic, strong) UIView *nextTapArea;

@end

@implementation ChapterContentViewController

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /**
     * Swipe gesture can also fire when user scroll the page to go to the next page
     * Therefore, in any case, do not fire the next page action when user swipe
     * Instead, detect the swipe and only fire action on the last page to go to the next chapter
     */
    [self loadSwipeLeft];
    [self loadSwipeRight];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    /**
     * Tap on the left and right side of the screen should go to the next and previous page
     * This tap should not be simultaneously recognized with other tap gesture
     */
    [self loadNextPageTap];
    [self loadPreviousPageTap];
}

- (void)loadNextPageTap
{
    if ([self.nextTapArea respondsToSelector:@selector(removeFromSuperview)]) {
        [self.nextTapArea removeFromSuperview];
        self.nextTapArea = nil;
    }
    
    UITapGestureRecognizer *nextTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(nextPageTap:)];
    CGFloat switchPageAreaWidth = self.view.frame.size.width / 5;
    CGRect nextTapAreaFrame = CGRectMake(self.view.frame.size.width - switchPageAreaWidth, 0, switchPageAreaWidth, self.view.frame.size.height);
    self.nextTapArea = [[UIView alloc] initWithFrame:nextTapAreaFrame];
    [self.nextTapArea addGestureRecognizer:nextTapGesture];
    [self.view addSubview:self.nextTapArea];
}

- (void)loadPreviousPageTap
{
    if ([self.previousTapArea respondsToSelector:@selector(removeFromSuperview)]) {
        [self.previousTapArea removeFromSuperview];
        self.previousTapArea = nil;
    }
    
    UITapGestureRecognizer *previousTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                         action:@selector(previousPageTap:)];
    CGFloat switchPageAreaWidth = self.view.frame.size.width / 5;
    CGRect previousTapAreaFrame = CGRectMake(0, 0, switchPageAreaWidth, self.view.frame.size.height);
    self.previousTapArea = [[UIView alloc] initWithFrame:previousTapAreaFrame];
    [self.previousTapArea addGestureRecognizer:previousTapGesture];
    [self.view addSubview:self.previousTapArea];
}

- (void)loadSwipeLeft
{

    UISwipeGestureRecognizer *swipeLeftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(swipeLeft:)];
    swipeLeftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeLeftGesture.delegate = self;
    [self.view addGestureRecognizer:swipeLeftGesture];
}

- (void)loadSwipeRight
{
    UISwipeGestureRecognizer *swipeRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(swipeRight:)];
    swipeRightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    swipeRightGesture.delegate = self;
    [self.view addGestureRecognizer:swipeRightGesture];
}

- (void)previousPageTap:(UIGestureRecognizer *)gestureRecognizer
{
    [self.delegate previousPage];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"View Manga Pages"
                                                          action:@"Previous Page by Tapping"
                                                           label:self.pageSetting == SETTING_1_PAGE ? @"Single" : @"Double"
                                                           value:nil] build]];
}

- (void)nextPageTap:(UIGestureRecognizer *)gestureRecognizer
{
    [self.delegate nextPage];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"View Manga Pages"
                                                          action:@"Next Page by Tapping"
                                                           label:self.pageSetting == SETTING_1_PAGE ? @"Single" : @"Double"
                                                           value:nil] build]];
}

- (void)swipeLeft:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.index >= self.childViewsCount - 1) {
        [self.delegate autoNextChapter];
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"View Manga Pages"
                                                              action:@"Swipe Left on last page"
                                                               label:self.pageSetting == SETTING_1_PAGE ? @"Single" : @"Double"
                                                               value:nil] build]];
    }
}

- (void)swipeRight:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.index == 0) {
        [self.delegate autoPreviousChapter];
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"View Manga Pages"
                                                              action:@"Swipe Right on first page"
                                                               label:self.pageSetting == SETTING_1_PAGE ? @"Single" : @"Double"
                                                               value:nil] build]];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - Properties

- (NSInteger)childViewsCount
{
    if (self.pageSetting == SETTING_2_PAGES) {
        return ceil((double)[self.chapter.pagesCount intValue] / 2);
    } else {
        return [self.chapter.pagesCount intValue];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[ImageViewController class]]) {
        ImageViewController *ivc = (ImageViewController *)segue.destinationViewController;
        ivc.pageSetting = self.pageSetting;
        ivc.chapter = self.chapter;
        
        if ([segue.identifier isEqualToString:@"Show Single Page"]) {
            // On single page view, page index = child view index
            ivc.pageIndex = self.index;
        } else if ([segue.identifier isEqualToString:@"Show First Page"]) {
            // On double page view, first page index = child view index * 2
            ivc.pageIndex = self.index * 2;
        } else if ([segue.identifier isEqualToString:@"Show Second Page"]) {
            // On double page view, second page index = child view index * 2 + 1
            ivc.pageIndex = self.index * 2 + 1;
        }
    }
}

@end
