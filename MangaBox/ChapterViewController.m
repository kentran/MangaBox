//
//  ChapterViewController.m
//  MangaBox
//
//  Created by Ken Tran on 28/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "ChapterViewController.h"
#import "Chapter+Lookup.h"
#import "ImageViewController.h"
#import "DownloadManager.h"
#import "Chapter+UpdateInfo.h"
#import "ChapterContentViewController.h"

@interface ChapterViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *pageSettingButton;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapScreen;
@property (nonatomic)  NSInteger pageSetting;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *lockRotationButton;

@property (nonatomic, strong) Chapter *previousChapter;
@property (nonatomic, strong) Chapter *nextChapter;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;

@property (nonatomic)  NSInteger currentPage;

@property (nonatomic, strong) id<GAITracker> tracker;

@property (nonatomic) NSInteger childViewsCount;

/* UIPageViewController */
@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic) NSInteger currentChildIndex;

@end

@implementation ChapterViewController

#pragma mark - View Layout

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addGestureRecognizer:self.tapScreen];
    if (!self.previousChapter) self.previousButton.enabled = NO;
    if (!self.nextChapter) self.nextButton.enabled = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(autoNextChapter)
                                                 name:autoNextChapterNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(autoPreviousChapter)
                                                 name:autoPreviousChapterNotification object:nil];
    
    self.navigationController.toolbar.barStyle = UIBarStyleBlackTranslucent;
    self.navigationController.navigationBar.backItem.title = @" ";
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    // Set frame size for UIPageViewController based on rotation
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        // Landscape
        self.pageViewController.view.frame = CGRectMake(0, 0, screenRect.size.height, screenRect.size.width);
        self.pageSettingButton.enabled = YES;
    } else {
        // Portrait
        self.pageViewController.view.frame = CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);
        self.pageSettingButton.enabled = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.tracker set:kGAIScreenName value:@"Reading Screen"];
    [self.tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES animated:NO];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // Setup the page view controller again when rotate to new view
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        // Landscape
    } else {
        // Portrait
        if (self.pageSetting == SETTING_2_PAGES) {
            [self performSelectorOnMainThread:@selector(pageSettingButtonTap:)
                                   withObject:self.pageSettingButton
                                waitUntilDone:YES];
        }
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    if ([self.lockRotationButton.title isEqualToString:@"🔒"])
        return NO;
    else
        return YES;
}

#pragma mark - Properties

- (id<GAITracker>)tracker
{
    return [[GAI sharedInstance] defaultTracker];
}

- (NSInteger)pageSetting
{
    if (!_pageSetting) {
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            // Landscape
            _pageSetting = SETTING_2_PAGES;
            self.pageSettingButton.title = SHOW_1_PAGE;

        } else {
            _pageSetting = SETTING_1_PAGE;
            self.pageSettingButton.title = SHOW_2_PAGES;
        }
    }
    
    return _pageSetting;
}

- (void)setChapter:(Chapter *)chapter
{
    _chapter = chapter;
    
    // Fire the download if not downloaded or downloading
    if (![chapter.downloadStatus isEqualToString:CHAPTER_DOWNLOADED]
        && ![chapter.downloadStatus isEqualToString:CHAPTER_DOWNLOADING])
    {
        [[DownloadManager sharedManager] startDownloadingChapter:chapter];
    }
    
    self.currentChildIndex = [self childIndexForCurrentSetting];
    [self setupPageViewController];
    
    // update status of the previous and next button
    if (!self.previousChapter) self.previousButton.enabled = NO;
    else self.previousButton.enabled = YES;
    if (!self.nextChapter) self.nextButton.enabled = NO;
    else self.nextButton.enabled = YES;

    self.currentPage = [chapter.currentPageIndex intValue] + 1;
}

// return the child index based on the currentPageIndex of each chapter
- (NSInteger)childIndexForCurrentSetting
{
    NSInteger currentPageIndex = [self.chapter.currentPageIndex intValue];
    if (self.pageSetting == SETTING_2_PAGES && currentPageIndex % 2) {
        // If setting is 2 page and the current page index is odd,
        // display from the previous page index
        return floor(currentPageIndex / 2);
    }
    return currentPageIndex;
}

- (Chapter *)previousChapter
{
    return [self.chapter previousChapter];
}

- (Chapter *)nextChapter
{
    return [self.chapter nextChapter];
}

- (void)setCurrentPage:(NSInteger)currentPage
{
    _currentPage = currentPage;
    self.navigationItem.title = [NSString stringWithFormat:@"%ld/%d", (long)self.currentPage, [self.chapter.pagesCount intValue]];
    self.navigationController.navigationBar.backItem.title = @" ";
}

- (NSInteger)childViewsCount
{
    if (self.pageSetting == SETTING_2_PAGES) {
        return ceil((double)[self.chapter.pagesCount intValue] / 2);
    } else {
        return [self.chapter.pagesCount intValue];
    }
}

#pragma mark - Action

- (IBAction)previousButtonTap:(UIBarButtonItem *)sender
{
    [self cleanUpChapterPages:self.chapter];
    self.chapter = self.previousChapter;
    
    // Track the event
    [self trackEventWithLabel:@"Previous chapter tap" andValue:nil];
}

- (IBAction)nextButtonTap:(UIBarButtonItem *)sender
{
    [self cleanUpChapterPages:self.chapter];
    self.chapter = self.nextChapter;
    
    // Track the event
    [self trackEventWithLabel:@"Next chapter tap" andValue:nil];
}

- (void)cleanUpChapterPages:(Chapter *)chapter
{
    [chapter.managedObjectContext refreshObject:chapter mergeChanges:YES];
}

- (IBAction)toggleLockRotation:(UIBarButtonItem *)sender
{
    if ([sender.title isEqualToString:@"🔓"]) {
        sender.title = @"🔒";
        [self trackEventWithLabel:@"Toggle lock rotation" andValue:[NSNumber numberWithInt:1]];
    } else {
        sender.title = @"🔓";
        [self trackEventWithLabel:@"Toggle lock rotation" andValue:[NSNumber numberWithInt:0]];
    }
}

- (IBAction)toggleToolbar:(UITapGestureRecognizer *)sender
{
    if (self.navigationController.navigationBar.hidden == NO) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self.navigationController setToolbarHidden:YES animated:YES];
    } else {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self.navigationController setToolbarHidden:NO animated:YES];
    }
}

- (IBAction)pageSettingButtonTap:(UIBarButtonItem *)sender
{
    if ([sender.title isEqualToString:SHOW_2_PAGES]) {
        // From single page view to double page view
        self.currentChildIndex = ceil((double)self.currentPage / 2 - 1);
        self.pageSetting = SETTING_2_PAGES;
        sender.title = SHOW_1_PAGE;
        [self trackEventWithLabel:@"Change page setting" andValue:[NSNumber numberWithInt:SETTING_2_PAGES]];
    } else {
        // From double page view to single page view
        self.currentChildIndex = self.currentPage - 1;
        self.pageSetting = SETTING_1_PAGE;
        sender.title = SHOW_2_PAGES;
        [self trackEventWithLabel:@"Change page setting" andValue:[NSNumber numberWithInt:SETTING_1_PAGE]];
    }

    [self setupPageViewController];
}

- (void)trackEventWithLabel:(NSString *)label andValue:(NSNumber *)value
{
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                               action:@"button_press"
                                                                label:label
                                                                value:value] build]];
}

#pragma mark - UIPageViewController

- (void)setupPageViewController
{
    // Remove all previous setup
    [self.pageViewController willMoveToParentViewController:nil];
    [self.pageViewController removeFromParentViewController];
    [self.pageViewController.view removeFromSuperview];
    self.pageViewController = nil;
    
    // Create a PageViewController
    if (self.pageSetting == SETTING_2_PAGES) {
        //        NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:UIPageViewControllerSpineLocationMid] forKey: UIPageViewControllerOptionSpineLocationKey];
        
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:UIPageViewControllerSpineLocationMid], UIPageViewControllerOptionSpineLocationKey, @40, UIPageViewControllerOptionInterPageSpacingKey, nil];
        self.pageViewController = [[UIPageViewController alloc]
                                   initWithTransitionStyle: UIPageViewControllerTransitionStyleScroll
                                   navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                   options:options];
    } else {
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@40, UIPageViewControllerOptionInterPageSpacingKey, nil];
        self.pageViewController = [[UIPageViewController alloc]
                                   initWithTransitionStyle: UIPageViewControllerTransitionStyleScroll
                                   navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                   options:options];
    }
    
    
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    
    // Create the child view controller
    NSArray *viewControllers;
    if (self.pageSetting == SETTING_2_PAGES) {
        //        UIViewController *startingViewController1 = [self viewControllerAtIndex:self.currentPageIndex];
        //        UIViewController *startingViewController2 = [self viewControllerAtIndex:self.currentPageIndex+1];
        //        viewControllers = @[startingViewController1, startingViewController2];
        UIViewController *startingViewController1 = [self viewControllerAtIndex:self.currentChildIndex];
        viewControllers = @[startingViewController1];
    } else {
        UIViewController *startingViewController1 = [self viewControllerAtIndex:self.currentChildIndex];
        viewControllers = @[startingViewController1];
    }
    
    [self.pageViewController setViewControllers:viewControllers
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:NULL];
    
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray *)previousViewControllers
       transitionCompleted:(BOOL)completed
{
    if (completed) {
        // We do not update the page index when the page is loaded because it may not be accurate
        // the pageViewController always load the next page before it is displayed
        // we update the current page here as well as in the core data
        NSInteger currentChildIndex = ((ChapterContentViewController *)[pageViewController viewControllers][0]).index;
        NSInteger currentIndex;
        if (self.pageSetting == SETTING_1_PAGE) {
            currentIndex = currentChildIndex;
        } else {
            currentIndex = currentChildIndex * 2 + 1;
        }
        
        self.currentPage = currentIndex + 1;
        [self.chapter updateCurrentPageIndex:currentIndex];
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    NSLog(@"TEST: %d", [pendingViewControllers count]);
}


#pragma mark - PageViewController datasource


- (UIViewController *)viewControllerAtIndex:(NSInteger)index
{
    // Create ChapterContentViewController, pass the chapter and index
    // ChapterContentViewController will figure it out which page to display based on the settings
    ChapterContentViewController *childVC;
    if (self.pageSetting == SETTING_2_PAGES) {
        childVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DoublePage"];
    } else {
        childVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SinglePage"];
    }
    childVC.pageSetting = self.pageSetting;
    childVC.chapter = self.chapter;
    childVC.index = index;

    
    if (!(index <= ((int)self.childViewsCount - 1))) {
        // If there is no page downloaded
        // Busy waiting on another queue until download is finished
        dispatch_queue_t loadPageQ = dispatch_queue_create("Loading Page", NULL);
        dispatch_async(loadPageQ, ^{
            NSLog(@"Waiting");
            while (!(index <= ((int)self.childViewsCount - 1))) {}
            NSLog(@"Loading done");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setupPageViewController];
            });
        });
    }
    
    return childVC;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index = ((ChapterContentViewController *)viewController).index;
    
    if ((index == 0) || (index == NSNotFound)) {
        //[[NSNotificationCenter defaultCenter] postNotificationName:autoPreviousChapterNotification object:self];
        return nil;
    }
    
    index--;
    self.currentChildIndex = index;
    NSLog(@"%d -", self.currentChildIndex);
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger index = ((ChapterContentViewController *)viewController).index;
    
//    NSInteger lastAllowableIndex = [self.chapter.pages count]  - 1;
//    if (self.pageSetting == SETTING_2_PAGES) {
//        // if setting is 2 pages, we need to load a blank page at the end
//        // only need when the total pages is odd (when lastAllowableIndex is even)
//        if (!(lastAllowableIndex % 2)) {
//            lastAllowableIndex++;
//        }
//    }
//    
//    NSLog(@"Lastallowableindex: %d, %d", lastAllowableIndex, index);
//    if (index == NSNotFound || index == lastAllowableIndex) {
//        return nil;
//    }
    
    if (index == NSNotFound || index >= (self.childViewsCount - 1)) {
        return nil;
    }
    
    index++;
    self.currentChildIndex = index;
    NSLog(@"%d +", self.currentChildIndex);
    return [self viewControllerAtIndex:index];
}

#pragma mark - Auto Switch Chapter

- (BOOL)autoSwitchChapterEnable
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults valueForKey:AUTO_SWITCH_CHAPTER] isEqualToString:AUTO_SWITCH_CHAPTER_ON]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)autoNextChapter
{
    NSLog(@"Auto next");
    // Make sure the chapter is downloaded and at the end of the page before go to the next
    // check the end of the page using self.currentPage is more reliable
    if (self.nextChapter && [self autoSwitchChapterEnable]
        && [self.chapter.downloadStatus isEqualToString:CHAPTER_DOWNLOADED]
        && self.currentPage == [self.chapter.pages count])
    {
        [self performSelectorOnMainThread:@selector(nextButtonTap:) withObject:nil waitUntilDone:YES];
        [self notice:self.chapter.name];
        [self trackEventWithLabel:@"Auto Next Chapter" andValue:nil];
    }
}

- (void)autoPreviousChapter
{
    NSLog(@"Auto previous");
    // Make sure the chapter is at the beginning of the page before go to the next
    // check the beginning of the page using self.currentPage is more reliable
    if (self.previousChapter && [self autoSwitchChapterEnable]) {
        [self performSelectorOnMainThread:@selector(previousButtonTap:) withObject:nil waitUntilDone:YES];
        [self notice:self.chapter.name];
        [self trackEventWithLabel:@"Auto Previous Chapter" andValue:nil];
    }
}

#pragma mark - Alerts

#define DISMISS_INTERVAL 0.5

- (void)notice:(NSString *)msg
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Chapter Changed"
                                                        message:msg
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:nil];
    
    [alertView show];
    [self performSelector:@selector(dismissNotice:) withObject:alertView afterDelay:DISMISS_INTERVAL];
}

- (void)dismissNotice:(UIAlertView *)notice
{
    [notice dismissWithClickedButtonIndex:0 animated:YES];
}

@end
