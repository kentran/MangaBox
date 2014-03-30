//
//  ImagePVC.h
//  MangaBox
//
//  Created by Ken Tran on 17/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Chapter.h"

@interface ChapterPageViewController : UIViewController

@property (nonatomic, strong) Chapter *chapter;
@property (nonatomic) NSInteger pageSetting;
@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic) NSInteger currentPageIndex;

@end
