//
//  ImageViewController.h
//  Imaginarium
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Chapter.h"

@interface ImageViewController : UIViewController

@property (nonatomic, strong) Chapter *chapter;
@property NSInteger pageIndex;

@end
