//
//  UIImage+Filter.h
//  MangaBox
//
//  Created by Ken Tran on 5/7/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Filter)

- (UIImage *)imageByApplyingFilterNamed:(NSString *)filterName;

@end
