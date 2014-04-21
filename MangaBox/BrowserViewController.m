//
//  BrowserViewController.m
//  MangaBox
//
//  Created by Ken Tran on 22/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "BrowserViewController.h"
#import "AddMangaConfirmViewController.h"

@interface BrowserViewController () <UITextFieldDelegate, UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation BrowserViewController

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.searchField resignFirstResponder];
    [self loadWebpage];
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webView.delegate = self;
    self.searchField.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadWebpage];
}

- (IBAction)backButtonTap:(UIBarButtonItem *)sender
{
    [self.webView goBack];
}

- (void)loadWebpage
{
    NSString *searchedText = self.searchField.text;
    NSString *urlString;
    if ([searchedText hasPrefix:@"http://"]) {
        urlString = searchedText;
    } else {
        urlString = [NSString stringWithFormat:@"http://%@", searchedText];
    }
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.spinner startAnimating];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"failed: %@", error);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.spinner stopAnimating];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    // set the searchbar text to be the url of the current view
    self.searchField.text = [self.webView.request.URL absoluteString];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[AddMangaConfirmViewController class]]) {
        AddMangaConfirmViewController *amcvc = (AddMangaConfirmViewController *)segue.destinationViewController;
        amcvc.mangaURL = self.webView.request.URL;
    }
}

@end
