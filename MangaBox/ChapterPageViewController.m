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

@interface ChapterPageViewController () <UIPageViewControllerDataSource>

@end

@implementation ChapterPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create a PageViewController
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    ImageViewController *startingViewController = [self viewControllerAtIndex:0];
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
    if ([self.chapter.pages count] == 0)
        return nil;
    
    // Create a new view controller and pass suitable data.
    ImageViewController *ivc = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageViewController"];
    ivc.pageIndex = index;
    NSArray *pages = [self.chapter.pages allObjects];
    NSSortDescriptor *urlSort = [[NSSortDescriptor alloc] initWithKey:PAGE_URL
                                                            ascending:YES
                                                             selector:@selector(localizedStandardCompare:)];
    
    pages = [pages sortedArrayUsingDescriptors:@[urlSort]];
    Page *page = pages[index];
    ivc.image = [UIImage imageWithData:page.imageData];
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
