//
//  ImageScrollView.h
//  MangaBox
//
//  Created by Ken Tran on 21/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageScrollView : UIScrollView

// Model for this MVC ... an image to display
@property (nonatomic, strong) UIImage *image;

@property BOOL fitWidth;

@end
