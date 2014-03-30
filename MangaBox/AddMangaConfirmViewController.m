//
//  AddMangaConfirmViewController.m
//  MangaBox
//
//  Created by Ken Tran on 22/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "AddMangaConfirmViewController.h"
#import "MangafoxFetcher.h"
#import "MangareaderFetcher.h"
#import "MangaDictionaryDefinition.h"
#import "Manga+Create.h"
#import "Chapter+Create.h"
#import "MenuTabBarController.h"
#import "MangaBoxAppDelegate.h"

@interface AddMangaConfirmViewController ()
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
    Manga *newManga = [self storeNewManga:self.mangaDictionary];
    [self loadNewChapterList:self.chapterDictionaryList ofManga:newManga];
    
    // Switch to collection tab when done
    [self.tabBarController setSelectedIndex:0];
}

#pragma mark - Display Label

- (void)displayMangaInfo
{
    self.titleTextArea.text = [self.mangaDictionary objectForKey:MANGA_TITLE];
    self.authorTextLabel.text = [self.mangaDictionary objectForKey:MANGA_AUTHOR];
    self.artistTextLabel.text = [self.mangaDictionary objectForKey:MANGA_ARTIST];
    self.chapterTextLabel.text = [NSString stringWithFormat:@"%d", [self.chapterDictionaryList count]];
    self.genresTextArea.text = [self.mangaDictionary objectForKey:MANGA_GENRES];
    self.statusTextLabel.text = [self.mangaDictionary objectForKey:MANGA_COMPLETION_STATUS];
    [self.spinner stopAnimating];
    
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
    [(MangaBoxAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
}


#pragma mark - Download Tasks

- (void)fetchMangaInfo
{
    // Reset variable before fetching new data
    self.mangaDictionary = nil;
    self.coverURL = nil;
    self.chapterDictionaryList = nil;
    [self.spinner startAnimating];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.mangaURL];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
        completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
            if (!error) {
                if ([request.URL isEqual:self.mangaURL]) {
                    NSData *htmlData = [NSData dataWithContentsOfURL:location];
                    
                    NSArray *chapterList;
                    NSDictionary *mangaInfo;
                    if ([[self.mangaURL absoluteString] rangeOfString:@"mangafox.me"].location != NSNotFound) {
                        // Fetch mangaInfo
                        mangaInfo = [MangafoxFetcher parseMangaDetails:htmlData];
                        
                        // Fetch chapter list;
                        chapterList = [MangafoxFetcher parseChapterList:htmlData];
                    } else if([[self.mangaURL absoluteString] rangeOfString:@"mangareader.net"].location != NSNotFound) {
                        // Fetch mangaInfo
                        mangaInfo = [MangareaderFetcher parseMangaDetails:htmlData];
                        
                        // Fetch chapter list
                        chapterList = [MangareaderFetcher parseChapterList:htmlData];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // Set the variables
                        self.chapterDictionaryList = chapterList;
                        self.coverURL = [NSURL URLWithString:[mangaInfo objectForKey:MANGA_COVER_URL]];
                        [self.mangaDictionary setValuesForKeysWithDictionary:mangaInfo];
                        // Put manga url to dictionary as the fetcher may not return that
                        [self.mangaDictionary setObject:[self.mangaURL absoluteString] forKey:MANGA_URL];
                    });
                }
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
                }
            }];
        [task resume];
    }
}

@end
