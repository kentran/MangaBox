//
//  AdvancedSearchVC.h
//  MangaBox
//
//  Created by Ken Tran on 6/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewManager.h"

@protocol AdvancedSearchVCDelegate;

@interface AdvancedSearchVC : UIViewController <SubstitutableDetailViewController>

/// SubstitutableDetailViewController
@property (nonatomic, retain) UIBarButtonItem *navigationPaneBarButtonItem;

@property (nonatomic, weak) id<AdvancedSearchVCDelegate> delegate;

@end

@protocol AdvancedSearchVCDelegate <NSObject>

- (void)advancedSearchVC:(AdvancedSearchVC *)vc
selectedParams:(NSDictionary *)params;

@end
