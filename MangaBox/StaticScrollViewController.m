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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:self.navigationItem.title];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.scrollView layoutIfNeeded];
    self.scrollView.contentSize = self.contentView.bounds.size;
}

@end
