//
//  ImageViewController.h
//  Imaginarium
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewController : UIViewController

// Model for this MVC ... an image to display
@property (nonatomic, strong) UIImage *image;
@property NSUInteger pageIndex;

@end
