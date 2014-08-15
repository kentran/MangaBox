//
//  PopularTVC.m
//  MangaBox
//
//  Created by Ken Tran on 6/7/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "PopularTVC.h"
#import "MangaSummaryViewController.h"
#import "MangaFetcher.h"
#import "MangafoxFetcher.h"

@interface PopularTVC ()

@property (nonatomic, strong) NSMutableArray *updatedMangaList;
@property (nonatomic, strong) NSURL *popularLocalURL;

@end

@implementation PopularTVC

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadData];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
}

- (void)loadData
{
    NSURL *url;
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self.popularLocalURL path]]) {
        url = self.popularLocalURL;
    } else {
        url = [[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:@"popular"];
    }
    NSData *json = [NSData dataWithContentsOfURL:url];
    NSError *error;
    NSArray *propertiesList = [NSJSONSerialization JSONObjectWithData:json
                                                              options:NSJSONReadingAllowFragments
                                                                error:&error];
    
    self.mangaDictionaries = propertiesList;
    
    // Create a mutable version and put into updatedMangaList
    for (NSDictionary *mangaDictionary in self.mangaDictionaries) {
        NSMutableDictionary *mutableMangaDictionary = [NSMutableDictionary dictionaryWithDictionary:mangaDictionary];
        [self.updatedMangaList addObject:mutableMangaDictionary];
    }
}

- (void)refresh
{
    [self fetchMangasInfo];
}

#pragma mark - Load Popular Manga Data

#define MAX_COUNT_POPULAR 10

- (void)fetchMangasInfo
{
    self.updatedMangaList = nil;
    NSURL *url = [NSURL URLWithString:POPULAR_MANGA_URL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
        completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error) {
            if (!error) {
                NSData *htmlData = [NSData dataWithContentsOfURL:localfile];
                NSArray *result = [MangafoxFetcher parseFetchResult:htmlData];
                
                for (NSInteger i = 0; i < MAX_COUNT_POPULAR; i++) {
                    NSDictionary *mangaDictionary = result[i];
                    [self updateMangaDictionary:mangaDictionary];
                }
            }
        }];
    [task resume];
}

- (void)updateMangaDictionary:(NSDictionary *)mangaDictionary
{
    NSURL *mangaURL = [NSURL URLWithString:[mangaDictionary valueForKeyPath:MANGA_URL]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:mangaURL];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
        completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error) {
            if (!error) {
                if ([request.URL isEqual:mangaURL]) {
                    NSMutableDictionary *updatedMangaDictionary = [[NSMutableDictionary alloc] initWithDictionary:mangaDictionary];
            
                    NSDictionary *mangaInfo = [MangaFetcher parseMangaDetails:localfile ofSourceURL:mangaURL];
                    [updatedMangaDictionary setValuesForKeysWithDictionary:mangaInfo];
                    
                    [self.updatedMangaList addObject:updatedMangaDictionary];
                    if ([self.updatedMangaList count] == MAX_COUNT_POPULAR) {
                        NSError *error;
                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.updatedMangaList
                                                                           options:NSJSONWritingPrettyPrinted
                                                                             error:&error];
                        
                        if (error) {
                            NSLog(@"Error create JSON file for popular: %@", error);
                        } else {
                            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                            [jsonString writeToURL:self.popularLocalURL
                                        atomically:YES
                                          encoding:NSUTF8StringEncoding
                                             error:NULL];
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.mangaDictionaries = nil;
                            self.mangaDictionaries = self.updatedMangaList;
                            [self.refreshControl endRefreshing];
                        });
                    }
                }
            } else {
                NSLog(@"Ajax fails");
            }
        }];
    [task resume];
}

#pragma mark - Properties

- (void)setMangaDictionaries:(NSArray *)mangaDictionaries
{
    _mangaDictionaries = mangaDictionaries;
    [self.tableView reloadData];
}

- (NSMutableArray *)updatedMangaList
{
    if (!_updatedMangaList) _updatedMangaList = [[NSMutableArray alloc] init];
    return _updatedMangaList;
}

- (NSURL *)popularLocalURL
{
    if (!_popularLocalURL) {
        NSURL *documentURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                     inDomains:NSUserDomainMask] lastObject];
        _popularLocalURL = [documentURL URLByAppendingPathComponent:@"popular"];
    }
    return _popularLocalURL;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.mangaDictionaries count];
}

#define TITLE_LABEL_TAG 1
#define CHAPTERS_LABEL_TAG 2
#define VIEWS_LABEL_TAG 3
#define STATUS_LABEL_TAG 4
#define COVER_IMAGE_VIEW_TAG 5

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Popular Manga Cell" forIndexPath:indexPath];
    NSDictionary *mangaDictionary = self.mangaDictionaries[indexPath.row];
    
    // title
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:TITLE_LABEL_TAG];
    titleLabel.text = [mangaDictionary valueForKeyPath:MANGA_TITLE];
    
    // chapters
    UILabel *chaptersLabel = (UILabel *)[cell.contentView viewWithTag:CHAPTERS_LABEL_TAG];
    chaptersLabel.text = [NSString stringWithFormat:@"%@ Chapters", [mangaDictionary valueForKeyPath:MANGA_CHAPTERS]];
    
    // views
    UILabel *viewsLabel = (UILabel *)[cell.contentView viewWithTag:VIEWS_LABEL_TAG];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setGroupingSeparator:@","];
    
    // Put comma to big number
    NSNumber *viewsCount = [numberFormatter numberFromString:[mangaDictionary valueForKey:MANGA_VIEWS]];
    viewsLabel.text = [NSString stringWithFormat:@"%@ Views", [numberFormatter stringFromNumber:viewsCount]];
    
    // status
    UILabel *statusLabel = (UILabel *)[cell.contentView viewWithTag:STATUS_LABEL_TAG];
    statusLabel.text = [mangaDictionary valueForKeyPath:MANGA_COMPLETION_STATUS];
    
    // cover image
    UIImageView *coverImageView = (UIImageView *)[cell.contentView viewWithTag:COVER_IMAGE_VIEW_TAG];
    coverImageView.contentMode = UIViewContentModeScaleAspectFit;
    UIImage *coverImage = [mangaDictionary objectForKey:@"image"];
    if (coverImage) {
        coverImageView.image = coverImage;
    } else {
        NSURL *coverURL = [NSURL URLWithString:[mangaDictionary valueForKeyPath:MANGA_COVER_URL]];
        [self downloadImageWithURL:coverURL forCell:cell];
    }
    
    cell.backgroundColor = UIColorFromRGB(0x121314);
    
    return cell;
}

- (void)downloadImageWithURL:(NSURL *)coverURL forCell:(UITableViewCell *)cell
{
    if (coverURL) {
        NSURLRequest *request = [NSURLRequest requestWithURL:coverURL];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
            completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error) {
                if (!error) {
                    if ([request.URL isEqual:coverURL]) {
                        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:localfile]];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIImageView *coverImageView = (UIImageView *)[cell.contentView viewWithTag:COVER_IMAGE_VIEW_TAG];
                            coverImageView.image = image;
                            
                            // Update the manga dictionary in the array with the image
                            // So that we don't have to download again everytime
                            for (NSMutableDictionary *mangaDictionary in self.updatedMangaList) {
                                if ([[mangaDictionary valueForKeyPath:MANGA_COVER_URL] isEqualToString:[coverURL absoluteString]])
                                {
                                    [mangaDictionary setValue:image forKey:@"image"];
                                    self.mangaDictionaries = self.updatedMangaList;
                                }
                            }
                        });
                    }
                }
            }];
        [task resume];
    }
}

#pragma mark - Navigation

- (void)prepareViewController:(id)vc forSegue:(NSString *)segueIdentifer fromIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *mangaDictionary = self.mangaDictionaries[indexPath.row];

    if ([vc isKindOfClass:[MangaSummaryViewController class]]) {
        MangaSummaryViewController *msvc = (MangaSummaryViewController *)vc;
        msvc.mangaURL = [NSURL URLWithString:[mangaDictionary valueForKey:MANGA_URL]];
        msvc.title = [mangaDictionary valueForKey:MANGA_TITLE];
        msvc.chaptersCount = [mangaDictionary valueForKey:MANGA_CHAPTERS];
        msvc.mangaUnique = [mangaDictionary valueForKey:MANGA_UNIQUE];
    }
}

// boilerplate
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = nil;
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        indexPath = [self.tableView indexPathForCell:sender];
    }
    [self prepareViewController:segue.destinationViewController
                       forSegue:segue.identifier
                  fromIndexPath:indexPath];
}

// boilerplate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id detailvc = [self.splitViewController.viewControllers lastObject];
    if ([detailvc isKindOfClass:[UINavigationController class]]) {
        detailvc = [((UINavigationController *)detailvc).viewControllers firstObject];
        [self prepareViewController:detailvc
                           forSegue:nil
                      fromIndexPath:indexPath];
    }
}


@end
