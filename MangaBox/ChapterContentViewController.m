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

@end

@implementation ChapterContentViewController

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UISwipeGestureRecognizer *swipeLeftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(swipeLeft:)];
    swipeLeftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeLeftGesture.delegate = self;
    [self.view addGestureRecognizer:swipeLeftGesture];
    
    UISwipeGestureRecognizer *swipeRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(swipeRight:)];
    swipeRightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    swipeRightGesture.delegate = self;
    [self.view addGestureRecognizer:swipeRightGesture];
}

- (void)swipeLeft:(UIGestureRecognizer *)gestureRegcognizer
{
    NSLog(@"Swipe left");
    if (self.index >= self.childViewsCount - 1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:autoNextChapterNotification object:self];
    }
}

- (void)swipeRight:(UIGestureRecognizer *)gestureRegcognizer
{
    if (self.index == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:autoPreviousChapterNotification object:self];
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
