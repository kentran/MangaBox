//
//  ImagePVC.m
//  MangaBox
//
//  Created by Ken Tran on 17/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "ChapterPageViewController.h"
#import "ImageViewController.h"
#import "Page.h"
#import "ImageScrollView.h"

@interface ChapterPageViewController () <UIPageViewControllerDataSource>

@end

@implementation ChapterPageViewController

#pragma mark - Properties

- (void)setPageSetting:(NSInteger)pageSetting
{
    if (self.chapter && _pageSetting != pageSetting) {
        // Reload the pageviewcontroller when pageSetting changed
        _pageSetting = pageSetting;
        [self setupPageViewController];
    } else {
        _pageSetting = pageSetting;
    }
}

- (void)setChapter:(Chapter *)chapter
{
    _chapter = chapter;
    self.currentPageIndex = [self pageIndexForCurrentSetting];
    [self setupPageViewController];
}

- (NSInteger)pageIndexForCurrentSetting
{
    NSInteger currentPageIndex = [self.chapter.currentPageIndex intValue];
    if (self.pageSetting == SETTING_2_PAGES && currentPageIndex % 2) {
        // If setting is 2 page and the current page index is odd,
        // display from the previous page index
        currentPageIndex--;
    }
    return currentPageIndex;
}

#pragma mark - View Layout

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupPageViewController];
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    // Set frame size for UIPageViewController based on rotation
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        // Landscape
        self.pageViewController.view.frame = CGRectMake(0, 0, screenRect.size.height, screenRect.size.width);
    } else {
        // Portrait
        self.pageViewController.view.frame = CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // Setup the page view controller again when rotate to new view
    [self setupPageViewController];
}

- (void)setupPageViewController
{
    // Remove all previous setup
    [self.pageViewController willMoveToParentViewController:nil];
    [self.pageViewController removeFromParentViewController];
    [self.pageViewController.view removeFromSuperview];
    self.pageViewController = nil;
    
    // Create a PageViewController
    if (self.pageSetting == SETTING_2_PAGES) {
        NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:UIPageViewControllerSpineLocationMid] forKey: UIPageViewControllerOptionSpineLocationKey];
        
        self.pageViewController = [[UIPageViewController alloc]
                                   initWithTransitionStyle: UIPageViewControllerTransitionStylePageCurl
                                   navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                   options:options];
    } else {
        self.pageViewController = [[UIPageViewController alloc]
                                   initWithTransitionStyle: UIPageViewControllerTransitionStylePageCurl
                                   navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                   options:nil];
    }

    
    self.pageViewController.dataSource = self;
    
    // Create the child view controller
    NSArray *viewControllers;
    if (self.pageSetting == SETTING_2_PAGES) {
        ImageViewController *startingViewController1 = [self viewControllerAtIndex:self.currentPageIndex];
        ImageViewController *startingViewController2 = [self viewControllerAtIndex:self.currentPageIndex+1];
        viewControllers = @[startingViewController1, startingViewController2];
    } else {
        ImageViewController *startingViewController1 = [self viewControllerAtIndex:self.currentPageIndex];
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

- (ImageViewController *)viewControllerAtIndex:(NSUInteger)index
{
    // Create ImageViewController, pass the chapter and index
    // ImageViewController will figure it out which page to display
    ImageViewController *ivc = [[ImageViewController alloc] init];
    ivc.pageIndex = index;
    ivc.chapter = self.chapter;
    
    return ivc;
}

#pragma mark - PageViewController datasource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((ImageViewController *)viewController).pageIndex;
    self.currentPageIndex = index;
    
    if ((index == 0) || (index == NSNotFound)) {
        [[NSNotificationCenter defaultCenter] postNotificationName:autoPreviousChapterNotification object:self];
        return nil;
    }
    
    index--;
    self.currentPageIndex = index;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((ImageViewController *)viewController).pageIndex;
    self.currentPageIndex = index;
    
    NSInteger lastAllowableIndex = [self.chapter.pages count] - 1;
    if (self.pageSetting == SETTING_2_PAGES) {
        // if setting is 2 pages, we need to load a blank page at the end
        // only need when the total pages is odd (when lastAllowableIndex is even)
        if (!(lastAllowableIndex % 2)) {
            lastAllowableIndex++;
        }
    }

    if (index == NSNotFound || index > lastAllowableIndex - 1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:autoNextChapterNotification object:self];
        return nil;
    }

    index++;
    self.currentPageIndex = index;
    return [self viewControllerAtIndex:index];
}

@end
