//
//  BrowserViewController.m
//  MangaBox
//
//  Created by Ken Tran on 22/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "BrowserViewController.h"
#import "AddMangaConfirmViewController.h"

@interface BrowserViewController () <UISearchBarDelegate, UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation BrowserViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadWebpage];
}

- (void)loadWebpage
{
    NSString *searchedText = self.searchBar.text;
    NSString *urlString;
    if ([searchedText hasPrefix:@"http://"]) {
        urlString = searchedText;
    } else {
        urlString = [NSString stringWithFormat:@"http://%@", searchedText];
    }
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];   // hide keyboard
    [self loadWebpage];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.spinner startAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"failed: %@", error);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.spinner stopAnimating];
    // set the searchbar text to be the url of the current view
    self.searchBar.text = [self.webView.request.URL absoluteString];
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
