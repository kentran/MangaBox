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

@interface ChapterViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIGestureRecognizerDelegate, ChapterContentViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *pageSettingButton;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapScreen;
@property (nonatomic)  NSInteger pageSetting;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *lockRotationButton;

@property (nonatomic, strong) Chapter *previousChapter;
@property (nonatomic, strong) Chapter *nextChapter;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;

@property (nonatomic)  NSInteger currentPage;

@property (nonatomic, strong) id tracker;

@property (nonatomic) NSInteger childViewsCount;

/* UIPageViewController */
@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic) NSInteger currentChildIndex;

@property (nonatomic) NSInteger readingDirection;

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
                                             selector:@selector(checkNeedReload:)
                                                 name:finishDownloadChapterPage
                                               object:nil];
    
    self.navigationController.toolbar.barStyle = UIBarStyleBlackTranslucent;
    self.navigationController.navigationBar.backItem.title = @" ";
}

- (void)checkNeedReload:(NSNotification *)note
{
    NSDictionary *userInfo = note.userInfo;
    if ([userInfo[CHAPTER_NAME] isEqualToString:self.chapter.name]) {
        NSInteger currentMaxChildViews;
        if (self.pageSetting == SETTING_2_PAGES) {
            currentMaxChildViews = ceil((double)[self.chapter.pages count] / 2);
        } else {
            currentMaxChildViews = [self.chapter.pages count];
        }

        if (self.currentChildIndex <= currentMaxChildViews - 1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.currentChildIndex = [self childIndexForCurrentSetting];
                [self setupPageViewController];
            });
        }
    }
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
    [self.tracker send:[[GAIDictionaryBuilder createScreenView] build]];
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

#pragma mark - UIGestureRecoginizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}


#pragma mark - Properties

- (id)tracker
{
    return [[GAI sharedInstance] defaultTracker];
}

- (NSInteger)readingDirection
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults objectForKey:READING_DIRECTION] isEqualToString:READING_DIRECTION_L2R]) {
        return UIPageViewControllerNavigationDirectionForward;
    } else {
        return UIPageViewControllerNavigationDirectionReverse;
    }
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

    // Set the index to 0 if the chapter is at the end page
    if (currentPageIndex >= [self.chapter.pagesCount integerValue] - 1)
    {
        [self.chapter updateCurrentPageIndex:0];
        currentPageIndex = 0;
    }
    
    if (self.pageSetting == SETTING_2_PAGES) {
        // If setting is 2 pages: (0, 1) -> index 0, (2, 3) -> index 1 etc
        return floor(currentPageIndex / 2);
    }
    return currentPageIndex;
}

- (void)setCurrentPage:(NSInteger)currentPage
{
    _currentPage = currentPage;
    self.navigationItem.title = [NSString stringWithFormat:@"%@ %ld/%d", self.chapter.name, (long)self.currentPage, [self.chapter.pagesCount intValue]];
    self.navigationController.navigationBar.backItem.title = @" ";
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, 200, 24)];
    titleLabel.text = self.chapter.name;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [titleView addSubview:titleLabel];
    
    UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 24, 200, 44-24)];
    subtitleLabel.text = [NSString stringWithFormat:@"%ld/%d", (long)self.currentPage, [self.chapter.pagesCount intValue]];
    subtitleLabel.textAlignment = NSTextAlignmentCenter;
    subtitleLabel.textColor = [UIColor whiteColor];
    subtitleLabel.font = [UIFont systemFontOfSize:13.0f];
    [titleView addSubview:subtitleLabel];
    
    self.navigationItem.titleView = titleView;
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
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"View Manga Pages"
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
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@40, UIPageViewControllerOptionInterPageSpacingKey, nil];
    self.pageViewController = [[UIPageViewController alloc]
                               initWithTransitionStyle: UIPageViewControllerTransitionStyleScroll
                               navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                               options:options];
    
    
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    
    // Create the child view controller
    NSArray *viewControllers;
    UIViewController *startingViewController1 = [self viewControllerAtIndex:self.currentChildIndex];
    viewControllers = @[startingViewController1];
    
    [self.pageViewController setViewControllers:viewControllers
                                      direction:UIPageViewControllerNavigationDirectionReverse
                                       animated:NO
                                     completion:NULL];
    
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

#pragma mark - UIPageViewControllerDelegate

- (void)setupCurrentPage:(UIPageViewController *)pageViewController
{
    // We do not update the page index when the page is loaded because it may not be accurate
    // the pageViewController always load the next page before it is displayed
    // we update the current page here as well as in the core data
    self.currentChildIndex = ((ChapterContentViewController *)[pageViewController viewControllers][0]).index;
    NSInteger currentIndex;
    if (self.pageSetting == SETTING_1_PAGE) {
        currentIndex = self.currentChildIndex;
    } else {
        currentIndex = self.currentChildIndex * 2 + 1;
    }
    self.currentPage = currentIndex + 1;
    [self.chapter updateCurrentPageIndex:currentIndex];
}

- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray *)previousViewControllers
       transitionCompleted:(BOOL)completed
{
    if (completed) {
        [self setupCurrentPage:pageViewController];
    }
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
    childVC.delegate = self;
    childVC.pageSetting = self.pageSetting;
    childVC.chapter = self.chapter;
    childVC.index = index;
    
    return childVC;
}

/*
 * When page direction change, we also need to change how the datasource is retrieved
 */

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index = ((ChapterContentViewController *)viewController).index;
    
    
    if (self.readingDirection == UIPageViewControllerNavigationDirectionForward) {
        if ((index == 0) || (index == NSNotFound)) {
            return nil;
        }
        
        index--;
    } else {
        if (index == NSNotFound || index >= (self.childViewsCount - 1)) {
            return nil;
        }
        
        index++;
    }

    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger index = ((ChapterContentViewController *)viewController).index;
    
    if (self.readingDirection == UIPageViewControllerNavigationDirectionForward) {
        if (index == NSNotFound || index >= (self.childViewsCount - 1)) {
            return nil;
        }
        
        index++;
    } else {
        if ((index == 0) || (index == NSNotFound)) {
            return nil;
        }
        
        index--;
    }
    
    return [self viewControllerAtIndex:index];
}

#pragma mark - ChapterContentViewControllerDelegate
#pragma mark - Switch Page

- (void)previousPage
{
    if (self.currentChildIndex > 0) {
        // If the current page is not the first page, go to previous page
        self.currentChildIndex--;
        NSArray *viewControllers;
        UIViewController *startingViewController1 = [self viewControllerAtIndex:self.currentChildIndex];
        viewControllers = @[startingViewController1];
        
        NSInteger previousDirection;
        if (self.readingDirection == UIPageViewControllerNavigationDirectionForward) {
            previousDirection = UIPageViewControllerNavigationDirectionReverse;
        } else {
            previousDirection = UIPageViewControllerNavigationDirectionForward;
        }
        
        __weak ChapterViewController *weakSelf = self;
        [self.pageViewController setViewControllers:viewControllers
                                          direction:previousDirection
                                           animated:NO
                                         completion:^(BOOL finished) {
                                             if (finished) [weakSelf setupCurrentPage:weakSelf.pageViewController];
                                         }];
    } else {
        // If the current page is the first page, auto previous chapter
        [self autoPreviousChapter];
    }
}

- (void)nextPage
{
    if (self.currentChildIndex < self.childViewsCount - 1) {
        self.currentChildIndex++;
        NSArray *viewControllers;
        UIViewController *startingViewController1 = [self viewControllerAtIndex:self.currentChildIndex];
        viewControllers = @[startingViewController1];
        
        __weak ChapterViewController *weakSelf = self;
        [self.pageViewController setViewControllers:viewControllers
                                          direction:self.readingDirection
                                           animated:NO
             completion:^(BOOL finished) {
                 if (finished) {
                     [weakSelf setupCurrentPage:weakSelf.pageViewController];
                 }
             }];
    } else {
        // If the current page is the last page, auto next chapter
        [self autoNextChapter];
    }
}

#pragma mark - Auto Switch Chapter

- (Chapter *)previousChapter
{
    return [self.chapter previousChapter];
}

- (Chapter *)nextChapter
{
    return [self.chapter nextChapter];
}

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
        && [self.chapter.downloadStatus isEqualToString:CHAPTER_DOWNLOADED])
    {
        [self performSelectorOnMainThread:@selector(nextButtonTap:) withObject:nil waitUntilDone:YES];
        [self notice:self.chapter.name];
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"View Manga Pages"
                                                              action:@"Auto Next Chapter"
                                                               label:self.pageSetting == SETTING_1_PAGE ? @"Single" : @"Double"
                                                               value:nil] build]];
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
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"View Manga Pages"
                                                              action:@"Auto Previous Chapter"
                                                               label:self.pageSetting == SETTING_1_PAGE ? @"Single" : @"Double"
                                                               value:nil] build]];
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
