//
//  MenuTabBarController.m
//  MangaBox
//
//  Created by Ken Tran on 20/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "MenuTabBarController.h"
#import "MangasCDTVC.h"
#import "ChaptersByBookmarkCDTVC.h"

@interface MenuTabBarController () <UITabBarControllerDelegate>
@property (nonatomic, strong) NSDictionary *mangaInfo;
@end

@implementation MenuTabBarController

#pragma mark - View Controller Life Cycle

- (void)awakeFromNib
{
    self.delegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tabBar.translucent = YES;
}


#pragma mark - Properties

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    id vc = [self.viewControllers objectAtIndex:0];
    [self prepareViewController:vc];
}

#pragma mark - UITabBarController Delegate

- (void)tabBarController:(UITabBarController *)tabBarController
 didSelectViewController:(UIViewController *)viewController
{
    [self prepareViewController:viewController];
}

- (void)prepareViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        viewController = [((UINavigationController *)viewController).viewControllers firstObject];
    }
    if ([viewController isKindOfClass:[MangasCDTVC class]]) {
        MangasCDTVC *mcdtvc = (MangasCDTVC *)viewController;
        mcdtvc.managedObjectContext = self.managedObjectContext;
    } else if ([viewController isKindOfClass:[ChaptersByBookmarkCDTVC class]]) {
        ChaptersByBookmarkCDTVC *cbbcdtvc = (ChaptersByBookmarkCDTVC *)viewController;
        cbbcdtvc.managedObjectContext = self.managedObjectContext;
    }
}

#pragma mark - Observer

- (void)prepareToAddNewManga:(NSNotification *)notification
{
    self.mangaInfo = notification.userInfo;
    
    // Avoid nested pushing segue by calling search or add continuously
    // Pop the current Manga List before pushing the updated one
    id vc = [self.viewControllers objectAtIndex:0];
    if ([vc isKindOfClass:[UINavigationController class]]) {
        vc = (UINavigationController *)vc;
        if ([((UINavigationController *)vc).viewControllers count])
            [vc popToRootViewControllerAnimated:NO];
    }
    
    [self prepareViewController:self.viewControllers[0]];
    [self setSelectedIndex:0];
}

@end
