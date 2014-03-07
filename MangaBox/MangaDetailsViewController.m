//
//  MangaDetailsViewController.m
//  MangaBox
//
//  Created by Ken Tran on 2/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "MangaDetailsViewController.h"
#import "MangafoxFetcher.h"
#import "DetailViewManager.h"

@interface MangaDetailsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *chapterLabel;
@property (weak, nonatomic) IBOutlet UITextView *summaryTextArea;
@property (weak, nonatomic) IBOutlet UITextView *genresTextArea;


@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (strong, nonatomic) UIImage *cover;
@property (strong, nonatomic) NSURL *coverURL;


@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *detailsSummarySpinner;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *coverSpinner;
@end

@implementation MangaDetailsViewController

// -------------------------------------------------------------------------------
//	setNavigationPaneBarButtonItem:
//  Custom implementation for the navigationPaneBarButtonItem setter.
//  In addition to updating the _navigationPaneBarButtonItem ivar, it
//  reconfigures the toolbar to either show or hide the
//  navigationPaneBarButtonItem.
// -------------------------------------------------------------------------------
- (void)setNavigationPaneBarButtonItem:(UIBarButtonItem *)navigationPaneBarButtonItem
{
    if (navigationPaneBarButtonItem != _navigationPaneBarButtonItem) {
        //        if (navigationPaneBarButtonItem)
        //            [self.toolbar setItems:[NSArray arrayWithObject:navigationPaneBarButtonItem] animated:NO];
        //        else
        //            [self.toolbar setItems:nil animated:NO];
        
        _navigationPaneBarButtonItem = navigationPaneBarButtonItem;
    }
}

- (void)setMangaURL:(NSURL *)mangaURL
{
    _mangaURL = mangaURL;
}

- (void)setMangaUnique:(NSString *)mangaUnique
{
    _mangaUnique = mangaUnique;
    [self startDownloadingMangaDetailsSummary];
}

- (UIImage *)cover
{
    return self.coverImageView.image;
}

- (void)setCover:(UIImage *)cover
{
    self.coverImageView.image = cover;
    self.coverImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.coverSpinner stopAnimating];
}

- (void)setCoverURL:(NSURL *)coverURL
{
    _coverURL = coverURL;
    [self startDownloadingMangaCover];
}

- (void)setMangaDetails:(NSDictionary *)mangaDetails
{
    _mangaDetails = mangaDetails;
    self.coverURL = [NSURL URLWithString:[self.mangaDetails objectForKey:@"cover"]];
    [self displayMangaDetailsSummary];
}

- (void)setSummaryTextArea:(UITextView *)summaryTextArea
{
    _summaryTextArea = summaryTextArea;
}

- (void)setGenresTextArea:(UITextView *)genresTextArea
{
    _genresTextArea = genresTextArea;
    _genresTextArea.contentInset = UIEdgeInsetsMake(-4, -4, 0, 0);
}

- (void)displayMangaDetailsSummary
{
    if (self.mangaDetails) {
        self.authorLabel.text = [NSString stringWithFormat:@"%@", [self.mangaDetails objectForKey:@"author"]];
        self.artistLabel.text = [NSString stringWithFormat:@"%@", [self.mangaDetails objectForKey:@"artist"]];
        self.chapterLabel.text = [NSString stringWithFormat:@"%@", self.chaptersCount];
        self.genresTextArea.text = [NSString stringWithFormat:@"%@", [self.mangaDetails objectForKey:@"genres"]];
        self.summaryTextArea.text = [NSString stringWithFormat:@"%@", [self.mangaDetails objectForKey:@"summary"]];
        [self.detailsSummarySpinner stopAnimating];
    }
}

#pragma mark - Download Tasks

- (void)startDownloadingMangaCover
{
    self.cover = nil;
    
    if (self.coverURL) {
        [self.coverSpinner startAnimating];
        NSURLRequest *request = [NSURLRequest requestWithURL:self.coverURL];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
            completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error) {
                if (!error) {
                    if ([request.URL isEqual:self.coverURL]) {
                        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:localfile]];
                        dispatch_async(dispatch_get_main_queue(), ^{ self.cover = image; });
                    }
                }
            }];
        [task resume];
    }
}

- (void)startDownloadingMangaDetailsSummary
{
    self.mangaDetails = nil;

    if (self.mangaURL && self.mangaUnique) {
        [self.detailsSummarySpinner startAnimating];
        
        NSURL *url = [NSURL URLWithString:MANGAFOX_AJAX_SEARCH_URL];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"post"];
        NSString *post = [[NSString alloc] initWithFormat:@"sid=%@", self.mangaUnique];
        [request setValue:[NSString stringWithFormat:@"%d", [post length]] forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
# warning handle if ajax fails here
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
            completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                //this handler is not executing on the main queue so we can't do UI directly here
                if (!error) {
                    if ([request.URL isEqual:url]) {
                        NSString *urlString = [request.URL absoluteString];
                        NSData *htmlData = [NSData dataWithContentsOfURL:location];
                        
                        NSDictionary *mangaDetails;
                        if ([urlString rangeOfString:@"mangafox.me"].location != NSNotFound) {
                            mangaDetails = [MangafoxFetcher parseMangaDetailSummary:htmlData];
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (mangaDetails) self.mangaDetails = mangaDetails;
                        });
                    }
                }
            }];
        [task resume];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
