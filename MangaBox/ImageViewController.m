//
//  ImageViewController.m
//  Imaginarium
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController () <UIScrollViewDelegate>
@property (nonatomic, strong) UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *tapAreaForToolBar;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *showHideToolBar;
@end

@implementation ImageViewController

#pragma mark - View Controller Lifecycle

// add the UIImageView to the MVC's View

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.scrollView addSubview:self.imageView];
    [self.tapAreaForToolBar addGestureRecognizer:self.showHideToolBar];
}

#pragma mark - Properties

// lazy instantiation

- (UIImageView *)imageView
{
    if (!_imageView) _imageView = [[UIImageView alloc] init];
    return _imageView;
}

- (UITapGestureRecognizer *)showHideToolBar
{
    if (!_showHideToolBar) _showHideToolBar = [[UITapGestureRecognizer alloc] init];
    return _showHideToolBar;
}

// image property does not use an _image instance variable
// instead it just reports/sets the image in the imageView property
// thus we don't need @synthesize even though we implement both setter and getter

- (UIImage *)image
{
    return self.imageView.image;
}

- (void)setImage:(UIImage *)image
{
    // Create the frame for imageView on each orientation
    // so that full image is loaded from the start
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIDeviceOrientationIsPortrait(interfaceOrientation)) {
        self.imageView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, screenRect.size.width, screenRect.size.height);
    } else {
        //CGPoint center = self.view.center;
        NSLog(@"test");
        self.imageView.frame = CGRectMake(screenRect.size.height/4, self.view.frame.origin.y, screenRect.size.height/2, screenRect.size.width);
    }

    self.imageView.image = image; // does not change the frame of the UIImageView
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;

    // self.scrollView to be the screen size
    self.scrollView.contentSize = self.view.bounds.size;
}

- (void)setScrollView:(UIScrollView *)scrollView
{
    _scrollView = scrollView;
    
    // next three lines are necessary for zooming
    _scrollView.minimumZoomScale = 1.0;
    _scrollView.maximumZoomScale = 2.0;
    _scrollView.delegate = self;

    // next line is necessary in case self.image gets set before self.scrollView does
    // for example, prepareForSegue:sender: is called before outlet-setting phase
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    self.scrollView.contentSize = screenRect.size;
}

#pragma mark - UIScrollViewDelegate

// mandatory zooming method in UIScrollViewDelegate protocol

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
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

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // reset image
    self.image = self.image;
}


@end
