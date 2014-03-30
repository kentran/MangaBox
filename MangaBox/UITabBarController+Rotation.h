//
//  UITabBarController+Rotation.h
//  MangaBox
//
//  Created by Ken Tran on 28/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBarController (Rotation)

// Use the rotate of the current child view controller inside TabBarController
- (BOOL)shouldAutorotate;

@end
