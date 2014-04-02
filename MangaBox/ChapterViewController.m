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

@end

@implementation ChapterViewController

#pragma mark - View Layout

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
    self.chapter = self.previousChapter;
    [self prepareChapterPageViewController:self.chapterPVC toDisplayChapter:self.chapter];
}

- (IBAction)nextButtonTap:(UIBarButtonItem *)sender
{
    self.chapter = self.nextChapter;
    [self prepareChapterPageViewController:self.chapterPVC toDisplayChapter:self.chapter];
}

- (IBAction)toggleLockRotation:(UIBarButtonItem *)sender
{
    if ([sender.title isEqualToString:@"🔓"]) {
        sender.title = @"🔒";
    } else {
        sender.title = @"🔓";
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
    } else {
        self.pageSetting = SETTING_1_PAGE;
        sender.title = SHOW_2_PAGES;
    }

    self.chapterPVC.pageSetting = self.pageSetting;
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
    chapterPVC.chapter = chapter;
    chapterPVC.pageSetting = self.pageSetting;
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

- (void)autoNextChapter
{
    if (self.nextChapter) {
        [self performSelectorOnMainThread:@selector(nextButtonTap:) withObject:nil waitUntilDone:YES];
        [self notice:self.chapter.name];
    }
}

- (void)autoPreviousChapter
{
    if (self.previousChapter) {
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
