//
//  ImageViewController.m
//  Imaginarium
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import "ImageViewController.h"
#import "MangaDictionaryDefinition.h"
#import "Page+Getter.h"
#import "ImageScrollView.h"
#import "Chapter+Download.h"

@interface ImageViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *toggleToolbar;

@end

@implementation ImageViewController

#pragma mark - Properties

- (void)setChapter:(Chapter *)chapter
{
    _chapter = chapter;
    if ([chapter.pagesCount intValue] != [chapter.pages count])
        [chapter startDownloadingChapterPages];
    [self loadView];
}

- (UITapGestureRecognizer *)toggleToolbar
{
    if (!_toggleToolbar) _toggleToolbar = [[UITapGestureRecognizer alloc] init];
    return _toggleToolbar;
}

- (void)loadView
{
    Page *page = [Page pageOfChapter:self.chapter atIndex:self.pageIndex];

    // Prepare the ImageScroll View
    ImageScrollView *scrollView = [[ImageScrollView alloc] init];
    if (page)
        scrollView.image = [UIImage imageWithData:page.imageData];
    else
        scrollView.image = [UIImage imageNamed:@"blank"];
    
    // Replace the view property with the ImageScrollView
    self.view = scrollView;
    
    UIView *tapArea = [[UIView alloc] init];
    [tapArea addGestureRecognizer:self.toggleToolbar];
    [scrollView addSubview:tapArea];

    // Must set constraints on width and height absolutely somewhere for UIScrollView
    [tapArea setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tapArea(==scrollView)]|"
                                                                       options:NSLayoutFormatDirectionLeadingToTrailing
                                                                       metrics:nil
                                                                         views:NSDictionaryOfVariableBindings(tapArea,scrollView)]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tapArea(==scrollView)]|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(tapArea,scrollView)]];
    

}

#pragma mark - Gesture

- (IBAction)tapScreen:(UITapGestureRecognizer *)sender
{
    if (self.navigationController.navigationBar.hidden == NO) {
        [[self navigationController] setNavigationBarHidden:YES animated:YES];
    } else {
        [[self navigationController] setNavigationBarHidden:NO animated:YES];
    }
}


@end
