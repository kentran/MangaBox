//
//  UITabBarController+Rotation.m
//  MangaBox
//
//  Created by Ken Tran on 28/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "UITabBarController+Rotation.h"

@implementation UITabBarController (Rotation)

- (BOOL)shouldAutorotate
{
    return [[((UINavigationController *)self.selectedViewController).viewControllers lastObject] shouldAutorotate];
}

@end
