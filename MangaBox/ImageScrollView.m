//
//  ImageScrollView.m
//  MangaBox
//
//  Created by Ken Tran on 21/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "ImageScrollView.h"

@interface ImageScrollView() <UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView *imageView;

@property CGSize imageSize;

@property CGPoint pointToCenterAfterResize;
@property CGFloat scaleToRestoreAfterResize;

@end

@implementation ImageScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.bouncesZoom = YES;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(doubleTap:)];
        tapGesture.numberOfTapsRequired = 2;
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)doubleTap:(UIGestureRecognizer *)gestureRecognizer
{
    CGFloat doubleTapZoomScale = self.minimumZoomScale + (self.maximumZoomScale - self.minimumZoomScale) / 2;
    if (self.zoomScale > self.minimumZoomScale) {
        [self setZoomScale:self.minimumZoomScale animated:YES];
    } else {
        [self setZoomScale:doubleTapZoomScale animated:YES];
    }
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    [self displayImage];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Center the imageView as it become smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = self.imageView.frame;
    
    // Center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // Center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    self.imageView.frame = frameToCenter;
}

- (void)setFrame:(CGRect)frame {
    BOOL sizeChanging = !CGSizeEqualToSize(frame.size, self.frame.size);

    if (sizeChanging) {
        [self prepareToResize];
    }
    
    [super setFrame:frame];
    
    if (sizeChanging) {
        [self recoverFromResizing];
    }
}

#pragma mark - Configure ScrollView to display image

- (void)displayImage
{
    // Clear the previous image if exist
    [self.imageView removeFromSuperview];
    self.imageView = nil;
    
    // Reset zoom scale before any further calculation
    self.zoomScale = 1.0;
    
    // Make a new UIImageView for image
    self.imageView = [[UIImageView alloc] initWithImage:self.image];
    [self addSubview:self.imageView];
    
    [self configureForImageSize];
}

- (void)configureForImageSize
{
    self.imageSize = self.image.size;
    self.contentSize = self.imageSize;
    [self setMaxMinZoomScalesForCurrentBounds];
    self.zoomScale = self.minimumZoomScale;
}

- (void)setMaxMinZoomScalesForCurrentBounds
{
    CGSize boundsSize = self.bounds.size;
    
    // calculate min/max zoomscale
    CGFloat xScale = boundsSize.width  / self.imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / self.imageSize.height;   // the scale needed to perfectly fit the image height-wise
    
    // Fill the smaller scale
    CGFloat minScale = MIN(xScale, yScale);
    
    CGFloat maxScale = 2.0;
    
    // don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.)
    if (minScale > maxScale) {
        minScale = maxScale;
    }
    
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
}

#pragma mark - Methods called during rotation to preserve the zoomScale and the visible portion of the image

- (void)prepareToResize
{
    CGPoint boundsCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    self.pointToCenterAfterResize = [self convertPoint:boundsCenter toView:self.imageView];
    
    self.scaleToRestoreAfterResize = self.zoomScale;
    
    // If we're at the minimum zoom scale, preserve that by returning 0, which will be converted to the minimum
    // allowable scale when the scale is restored.
    if (self.scaleToRestoreAfterResize <= self.minimumZoomScale + FLT_EPSILON)
        self.scaleToRestoreAfterResize = 0;
}

- (void)recoverFromResizing
{
    [self setMaxMinZoomScalesForCurrentBounds];
    
    // Step 1: restore zoom scale, first making sure it is within the allowable range.
    CGFloat maxZoomScale = MAX(self.minimumZoomScale, self.scaleToRestoreAfterResize);
    self.zoomScale = MIN(self.maximumZoomScale, maxZoomScale);
    
    // Step 2: restore center point, first making sure it is within the allowable range.
    
    // 2a: convert our desired center point back to our own coordinate space
    CGPoint boundsCenter = [self convertPoint:self.pointToCenterAfterResize fromView:self.imageView];
    
    // 2b: calculate the content offset that would yield that center point
    CGPoint offset = CGPointMake(boundsCenter.x - self.bounds.size.width / 2.0,
                                 boundsCenter.y - self.bounds.size.height / 2.0);
    
    // 2c: restore offset, adjusted to be within the allowable range
    CGPoint maxOffset = [self maximumContentOffset];
    CGPoint minOffset = [self minimumContentOffset];
    
    CGFloat realMaxOffset = MIN(maxOffset.x, offset.x);
    offset.x = MAX(minOffset.x, realMaxOffset);
    
    realMaxOffset = MIN(maxOffset.y, offset.y);
    offset.y = MAX(minOffset.y, realMaxOffset);
    
    self.contentOffset = offset;
}

- (CGPoint)maximumContentOffset
{
    CGSize contentSize = self.contentSize;
    CGSize boundsSize = self.bounds.size;
    return CGPointMake(contentSize.width - boundsSize.width, contentSize.height - boundsSize.height);
}

- (CGPoint)minimumContentOffset
{
    return CGPointZero;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

@end
