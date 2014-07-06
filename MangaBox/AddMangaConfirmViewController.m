//
//  AddMangaConfirmViewController.m
//  MangaBox
//
//  Created by Ken Tran on 22/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "AddMangaConfirmViewController.h"
#import "Manga+Create.h"
#import "Chapter+Create.h"
#import "MenuTabBarController.h"
#import "MangaFetcher.h"
#import "ChaptersByMangaCDTVC.h"
#import "MangaViewController.h"

@interface AddMangaConfirmViewController () <UIAlertViewDelegate>
@property (nonatomic, strong) NSArray *chapterDictionaryList;
@property (nonatomic, strong) NSMutableDictionary *mangaDictionary;

@property (nonatomic, strong) NSURL *coverURL;
@property (nonatomic, strong) UIImage *coverImage;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext; // to save to core data

// Outlet
@property (weak, nonatomic) IBOutlet UITextView *titleTextArea;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *authorTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *chapterTextLabel;
@property (weak, nonatomic) IBOutlet UITextView *genresTextArea;
@property (weak, nonatomic) IBOutlet UILabel *statusTextLabel;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *confirmButton;


@end

@implementation AddMangaConfirmViewController

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imageView.hidden = YES;
    self.imageView.layer.masksToBounds = NO;
    self.imageView.layer.shadowRadius = 2;
    self.imageView.layer.shadowOpacity = 0.2f;
    self.imageView.layer.borderWidth = 1;
    self.imageView.layer.borderColor = UIColorFromRGB(0xbfbfbf).CGColor;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Add Manga Confirm Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

#pragma mark - Properties

- (NSMutableDictionary *)mangaDictionary
{
    if (!_mangaDictionary) _mangaDictionary = [[NSMutableDictionary alloc] init];
    return _mangaDictionary;
}

- (void)setMangaURL:(NSURL *)mangaURL
{
    _mangaURL = mangaURL;
    [self fetchMangaInfo];
}

- (void)setCoverURL:(NSURL *)coverURL
{
    _coverURL = coverURL;
    [self startDownloadingMangaCover];
}

- (UIImage *)coverImage
{
    return self.imageView.image;
}

- (void)setCoverImage:(UIImage *)coverImage
{
    self.imageView.image = coverImage;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self displayMangaInfo];
    [self.mangaDictionary setObject:UIImageJPEGRepresentation(coverImage, 1.0) forKey:MANGA_COVER_DATA];
}

- (void)setGenresTextArea:(UITextView *)genresTextArea
{
    _genresTextArea = genresTextArea;
    _genresTextArea.contentInset = UIEdgeInsetsMake(-4, -4, 0, 0);
}

- (void)setTitleTextArea:(UITextView *)titleTextArea
{
    _titleTextArea = titleTextArea;
    _titleTextArea.contentInset = UIEdgeInsetsMake(-4, -4, 0, 0);
}

- (void)setChapterDictionaryList:(NSArray *)chapterDictionaryList
{
    _chapterDictionaryList = chapterDictionaryList;
    [self.tableView reloadData];
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    [self addMangaAndNavigate];
}

- (void)addMangaAndNavigate
{
    Manga *newManga = [self storeNewManga:self.mangaDictionary];
    [self loadNewChapterList:self.chapterDictionaryList ofManga:newManga];
    
    // When done, switch to collection tab
    [self.tabBarController setSelectedIndex:0];
    
    // Navigate the navigation controller to the new manga
    UINavigationController *navigationController = (UINavigationController *)self.tabBarController.viewControllers[0];
    [navigationController popToRootViewControllerAnimated:NO];
    MangaViewController *mangaVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Chapters List"];
    mangaVC.manga = newManga;
    [navigationController pushViewController:mangaVC animated:YES];
}

#pragma mark - Display Label

- (void)displayMangaInfo
{
    self.titleTextArea.text = [self.mangaDictionary objectForKey:MANGA_TITLE];
    self.authorTextLabel.text = [self.mangaDictionary objectForKey:MANGA_AUTHOR];
    self.artistTextLabel.text = [self.mangaDictionary objectForKey:MANGA_ARTIST];
    self.chapterTextLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)[self.chapterDictionaryList count]];
    self.genresTextArea.text = [self.mangaDictionary objectForKey:MANGA_GENRES];
    self.statusTextLabel.text = [self.mangaDictionary objectForKey:MANGA_COMPLETION_STATUS];
    [self.spinner stopAnimating];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    // Show the labels
    for (UIView *subview in self.infoView.subviews)
    {
        if (![subview isKindOfClass:[UIActivityIndicatorView class]]) {
            subview.hidden = NO;
        }
    }
    
    // Enable the confirm button
    self.confirmButton.enabled = YES;
}

#pragma UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.chapterDictionaryList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Parsed Chapter Cell"];
    
    cell.textLabel.text = [self.chapterDictionaryList[indexPath.row] objectForKey:CHAPTER_NAME];

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Chapter List";
}

#pragma mark - Confirm Add Manga

- (IBAction)confirm:(UIBarButtonItem *)sender
{
    // Get the managedObjectContext from tabBarController which is set when the app launched
    if ([self.tabBarController isKindOfClass:[MenuTabBarController class]]) {
        MenuTabBarController *mtbc = (MenuTabBarController *)self.tabBarController;
        self.managedObjectContext = mtbc.managedObjectContext;
    }
}

- (Manga *)storeNewManga:(NSDictionary *)newManga
{
    return [Manga mangaWithInfo:newManga inManagedObjectContext:self.managedObjectContext];
}

- (void)loadNewChapterList:(NSArray *)newChapterList
                   ofManga:(Manga *)manga
{
    [Chapter loadChaptersFromArray:newChapterList
                           ofManga:manga
          intoManagedObjectContext:self.managedObjectContext];
}


#pragma mark - Download Tasks

- (void)fetchMangaInfo
{
    // Reset variable before fetching new data
    self.mangaDictionary = nil;
    self.coverURL = nil;
    self.chapterDictionaryList = nil;
    [self.spinner startAnimating];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.mangaURL];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
        completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error) {
            if (!error) {
                if ([request.URL isEqual:self.mangaURL]) {
                    NSDictionary *mangaInfo = [MangaFetcher parseMangaDetails:localfile ofSourceURL:self.mangaURL];
                    NSArray *chapterList = [MangaFetcher parseChapterList:localfile ofSourceURL:self.mangaURL];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (!mangaInfo || !chapterList) {
                            [self fatalAlert:PARSE_MANGA_ERROR];
                            return;
                        }
                        
                        // Set the variables
                        self.chapterDictionaryList = chapterList;
                        self.coverURL = [NSURL URLWithString:[mangaInfo objectForKey:MANGA_COVER_URL]];
                        [self.mangaDictionary setValuesForKeysWithDictionary:mangaInfo];
                        // Put manga url to dictionary as the fetcher may not return that
                        [self.mangaDictionary setObject:[self.mangaURL absoluteString] forKey:MANGA_URL];
                    });
                }
            } else {
                NSLog(@"Error parsing manga info");
                [self fatalAlert:PARSE_MANGA_ERROR];
            }
        }];
    [task resume];
}

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
                        dispatch_async(dispatch_get_main_queue(), ^{ self.coverImage = image; });
                    }
                } else {
                    NSLog(@"Error downloading manga cover");
                }
            }];
        [task resume];
    }
}

#pragma mark - Alerts

- (void)fatalAlert:(NSString *)msg
{
    [[[UIAlertView alloc] initWithTitle:@"Error"
                                message:msg
                               delegate:self
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
