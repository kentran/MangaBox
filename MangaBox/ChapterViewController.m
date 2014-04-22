//
//  ChapterViewController.m
//  MangaBox
//
//  Created by Ken Tran on 28/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "ChapterViewController.h"
#import "ChapterPageViewController.h"
#import "MangaDictionaryDefinition.h"
#import "Chapter+Lookup.h"
#import "ImageViewController.h"
#import "MangaBoxNotification.h"
#import "MangaBoxSettingsPropertyKeys.h"

@interface ChapterViewController () <UIPageViewControllerDelegate>

@property (nonatomic, strong) ChapterPageViewController *chapterPVC;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *pageSettingButton;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapScreen;
@property (nonatomic)  NSInteger pageSetting;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *lockRotationButton;

@property (nonatomic, strong) Chapter *previousChapter;
@property (nonatomic, strong) Chapter *nextChapter;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;

@property (nonatomic)  NSInteger currentPage;

@property (nonatomic, strong) id<GAITracker> tracker;

@end

@implementation ChapterViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.tracker set:kGAIScreenName value:@"Reading Screen"];
    [self.tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

#pragma mark - View Layout

- (void)dealloc
{
    // save the current page index before removing viewcontroller
    self.chapter.currentPageIndex = [NSNumber numberWithInteger:self.chapterPVC.currentPageIndex];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addGestureRecognizer:self.tapScreen];
    if (!self.previousChapter) self.previousButton.enabled = NO;
    if (!self.nextChapter) self.nextButton.enabled = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(autoNextChapter)
                                                 name:autoNextChapterNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(autoPreviousChapter)
                                                 name:autoPreviousChapterNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES animated:NO];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    [super shouldAutorotate];
    if ([self.lockRotationButton.title isEqualToString:@"🔒"])
        return NO;
    else
        return YES;
}

#pragma mark - Properties

- (id<GAITracker>)tracker
{
    return [[GAI sharedInstance] defaultTracker];
}

- (NSInteger)pageSetting
{
    if (!_pageSetting) {
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            // Landscape
            _pageSetting = SETTING_2_PAGES;
            self.pageSettingButton.title = SHOW_1_PAGE;

        } else {
            _pageSetting = SETTING_1_PAGE;
            self.pageSettingButton.title = SHOW_2_PAGES;
        }
    }
    
    return _pageSetting;
}

- (void)setChapter:(Chapter *)chapter
{
    _chapter = chapter;
    [self prepareChapterPageViewController:self.chapterPVC toDisplayChapter:_chapter];
    
    // update status of the previous and next button
    if (!self.previousChapter) self.previousButton.enabled = NO;
    else self.previousButton.enabled = YES;
    if (!self.nextChapter) self.nextButton.enabled = NO;
    else self.nextButton.enabled = YES;

    self.currentPage = [chapter.currentPageIndex intValue] + 1;
}

- (Chapter *)previousChapter
{
    return [self.chapter previousChapter];
}

- (Chapter *)nextChapter
{
    return [self.chapter nextChapter];
}

- (void)setCurrentPage:(NSInteger)currentPage
{
    _currentPage = currentPage;
    self.navigationItem.title = [NSString stringWithFormat:@"%@ (%ld/%d)", self.chapter.name, (long)self.currentPage, [self.chapter.pagesCount intValue]];
}

#pragma mark - Action

- (IBAction)previousButtonTap:(UIBarButtonItem *)sender
{
    // save the current page index before navigate to other chapters
    self.chapter.currentPageIndex = [NSNumber numberWithInteger:self.chapterPVC.currentPageIndex];
    
    self.chapter = self.previousChapter;
    [self prepareChapterPageViewController:self.chapterPVC toDisplayChapter:self.chapter];
    
    // Track the event
    [self trackEventWithLabel:@"Previous chapter tap" andValue:nil];
}

- (IBAction)nextButtonTap:(UIBarButtonItem *)sender
{
    // save the current page index before navigate to other chapters
    self.chapter.currentPageIndex = [NSNumber numberWithInteger:self.chapterPVC.currentPageIndex];
    
    self.chapter = self.nextChapter;
    [self prepareChapterPageViewController:self.chapterPVC toDisplayChapter:self.chapter];
    
    // Track the event
    [self trackEventWithLabel:@"Next chapter tap" andValue:nil];
}

- (IBAction)toggleLockRotation:(UIBarButtonItem *)sender
{
    if ([sender.title isEqualToString:@"🔓"]) {
        sender.title = @"🔒";
        [self trackEventWithLabel:@"Toggle lock rotation" andValue:[NSNumber numberWithInt:1]];
    } else {
        sender.title = @"🔓";
        [self trackEventWithLabel:@"Toggle lock rotation" andValue:[NSNumber numberWithInt:0]];
    }
}

- (IBAction)toggleToolbar:(UITapGestureRecognizer *)sender
{
    if (self.navigationController.navigationBar.hidden == NO) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self.navigationController setToolbarHidden:YES animated:YES];
    } else {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self.navigationController setToolbarHidden:NO animated:YES];
    }
}

- (IBAction)pageSettingButtonTap:(UIBarButtonItem *)sender
{
    if ([sender.title isEqualToString:SHOW_2_PAGES]) {
        self.pageSetting = SETTING_2_PAGES;
        sender.title = SHOW_1_PAGE;
        [self trackEventWithLabel:@"Change page setting" andValue:[NSNumber numberWithInt:SETTING_2_PAGES]];
    } else {
        self.pageSetting = SETTING_1_PAGE;
        sender.title = SHOW_2_PAGES;
        [self trackEventWithLabel:@"Change page setting" andValue:[NSNumber numberWithInt:SETTING_1_PAGE]];
    }

    self.chapterPVC.pageSetting = self.pageSetting;
}

- (void)trackEventWithLabel:(NSString *)label andValue:(NSNumber *)value
{
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                               action:@"button_press"
                                                                label:label
                                                                value:value] build]];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.destinationViewController isKindOfClass:[ChapterPageViewController class]]) {
        ChapterPageViewController *chapterPVC = (ChapterPageViewController *)segue.destinationViewController;
        [self prepareChapterPageViewController:chapterPVC toDisplayChapter:self.chapter];
    } else {
        [super prepareForSegue:segue sender:sender];
    }
}

- (void)prepareChapterPageViewController:(ChapterPageViewController *)chapterPVC
                        toDisplayChapter:(Chapter *)chapter
{
    chapterPVC.title = chapter.name;
    chapterPVC.pageSetting = self.pageSetting;
    chapterPVC.chapter = chapter;
    chapterPVC.pageViewController.delegate = self;
    self.chapterPVC = chapterPVC;
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray *)previousViewControllers
       transitionCompleted:(BOOL)completed
{
    self.currentPage = self.chapterPVC.currentPageIndex + 1;
}

#pragma mark - Auto Switch Chapter

- (BOOL)autoSwitchChapterEnable
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults valueForKey:AUTO_SWITCH_CHAPTER] isEqualToString:AUTO_SWITCH_CHAPTER_ON]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)autoNextChapter
{
    if (self.nextChapter && [self autoSwitchChapterEnable]
        && [self.chapter.downloadStatus isEqualToString:CHAPTER_DOWNLOADED])
    {
        [self performSelectorOnMainThread:@selector(nextButtonTap:) withObject:nil waitUntilDone:YES];
        [self notice:self.chapter.name];
    }
}

- (void)autoPreviousChapter
{
    if (self.previousChapter && [self autoSwitchChapterEnable]) {
        [self performSelectorOnMainThread:@selector(previousButtonTap:) withObject:nil waitUntilDone:YES];
        [self notice:self.chapter.name];
    }
}

#pragma mark - Alerts

#define DISMISS_INTERVAL 1

- (void)notice:(NSString *)msg
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Chapter Changed"
                                                        message:msg
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:nil];
    
    [alertView show];
    [self performSelector:@selector(dismissNotice:) withObject:alertView afterDelay:DISMISS_INTERVAL];
}

- (void)dismissNotice:(UIAlertView *)notice
{
    [notice dismissWithClickedButtonIndex:0 animated:YES];
}

@end
