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
#import "MangaDictionaryDefinition.h"
#import "ImageScrollView.h"

@interface ChapterPageViewController () <UIPageViewControllerDataSource>

@end

@implementation ChapterPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create a PageViewController
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    ImageViewController *startingViewController = [self viewControllerAtIndex:[self.chapter.currentPageIndex intValue]];
    NSArray *viewControllers = @[startingViewController];
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
    ImageViewController *ivc = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageViewController"];
    ivc.pageIndex = index;
    ivc.chapter = self.chapter;
    
    return ivc;
}

#pragma mark - PageViewController datasource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((ImageViewController *)viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound))
        return nil;
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((ImageViewController *)viewController).pageIndex;
    
    if (index == NSNotFound)
        return nil;
    
    index++;
    if (index == [self.chapter.pages count])
        return nil;
    
    return [self viewControllerAtIndex:index];
}

@end
