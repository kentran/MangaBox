//
//  HelpBrowserViewController.m
//  MangaBox
//
//  Created by Ken Tran on 17/4/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "StaticScrollViewController.h"

@interface StaticScrollViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *contentView;

@end

@implementation StaticScrollViewController

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.scrollView layoutIfNeeded];
    self.scrollView.contentSize = self.contentView.bounds.size;
}

@end
