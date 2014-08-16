//
//  MangaDetailsViewController.m
//  MangaBox
//
//  Created by Ken Tran on 2/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "MangaSummaryViewController.h"
#import "MangafoxFetcher.h"
#import "AddMangaConfirmViewController.h"

@interface MangaSummaryViewController ()

@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *chapterLabel;
@property (weak, nonatomic) IBOutlet UITextView *summaryTextArea;
@property (weak, nonatomic) IBOutlet UITextView *genresTextArea;

@property (weak, nonatomic) IBOutlet UILabel *genresLabel;
@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (strong, nonatomic) UIImage *cover;
@property (strong, nonatomic) NSURL *coverURL;


@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *detailsSummarySpinner;
@property (weak, nonatomic) IBOutlet UIButton *addButton;

@property (strong, nonatomic) NSDictionary *mangaDetails;
@end

@implementation MangaSummaryViewController

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.addButton.backgroundColor = STATUS_SELECTED_LABEL_BACKGROUND_COLOR;
    [self.addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.addButton.layer.cornerRadius = 6.0f;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Manga Summary Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

#pragma mark - Properties

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
    self.coverImageView.contentMode = UIViewContentModeScaleToFill;
    
    [self.detailsSummarySpinner stopAnimating];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)setCoverURL:(NSURL *)coverURL
{
    _coverURL = coverURL;
    [self startDownloadingMangaCover];
}

- (void)setMangaDetails:(NSDictionary *)mangaDetails
{
    _mangaDetails = mangaDetails;
    self.coverURL = [NSURL URLWithString:[self.mangaDetails objectForKey:MANGA_COVER_URL]];
    [self setMangaDetailsSummaryLabel];
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

- (void)setMangaDetailsSummaryLabel
{
    if (self.mangaDetails) {
        self.authorLabel.text = [NSString stringWithFormat:@"%@", [self.mangaDetails objectForKey:MANGA_AUTHOR]];
        self.artistLabel.text = [NSString stringWithFormat:@"%@", [self.mangaDetails objectForKey:MANGA_ARTIST]];
        self.chapterLabel.text = [NSString stringWithFormat:@"%@", self.chaptersCount];
        self.genresLabel.text = [NSString stringWithFormat:@"%@", [self.mangaDetails objectForKey:MANGA_GENRES]];
        self.summaryLabel.text = [NSString stringWithFormat:@"%@", [self.mangaDetails objectForKey:MANGA_SUMMARY]];
        [self.detailsSummarySpinner stopAnimating];
        
        self.scrollView.hidden = NO;
    }
}

#pragma mark - Download Tasks

- (void)startDownloadingMangaCover
{
    if (self.coverURL) {
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
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        NSURL *url = [NSURL URLWithString:MANGAFOX_AJAX_SEARCH_URL];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"post"];
        NSString *post = [[NSString alloc] initWithFormat:@"sid=%@", self.mangaUnique];
        [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[post length]] forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];

        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
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
                } else {
                    NSLog(@"Ajax fails");
                }
            }];
        [task resume];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[AddMangaConfirmViewController class]]) {
        AddMangaConfirmViewController *amcvc = (AddMangaConfirmViewController *)segue.destinationViewController;
        amcvc.mangaURL = self.mangaURL;
    }
}

@end
