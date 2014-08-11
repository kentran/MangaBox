//
//  ChapterContentViewController.h
//  MangaBox
//
//  Created by Ken Tran on 4/8/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Chapter.h"

@interface ChapterContentViewController : UIViewController

@property (nonatomic, strong) Chapter *chapter;
@property (nonatomic) NSInteger pageSetting;
@property (nonatomic) NSInteger index;

@end
