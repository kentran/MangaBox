//
//  SearchedMangaViewController.m
//  MangaBox
//
//  Created by Ken Tran on 2/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "SearchedMangaViewController.h"
#import "MangafoxFetcher.h"

@interface SearchedMangaViewController ()
@property (strong, nonatomic) NSMutableDictionary *criteria;
@end

@implementation SearchedMangaViewController

- (NSMutableDictionary *)criteria
{
    if (!_criteria) _criteria = [[NSMutableDictionary alloc] init];
    return _criteria;
}

- (void)setName:(NSString *)name
{
    _name = name;
    [self.criteria setObject:self.name forKey:@"name"];
}

- (void)setAuthor:(NSString *)author
{
    _author = author;
    [self.criteria setObject:self.author forKey:@"author"];
}

- (void)setArtist:(NSString *)artist
{
    _artist = artist;
    [self.criteria setObject:self.artist forKey:@"artist"];
}

- (void)updateCriteria
{
    
    
    
}

- (NSArray *) fetchMangas
{
    NSLog(@"%@", self.criteria);
    NSURL *url = [MangafoxFetcher urlForFetchingMangas:self.criteria];
    dispatch_queue_t fetchQ = dispatch_queue_create("mangafox fetcher", NULL);
    dispatch_async(fetchQ, ^{
        NSData *htmlData = [NSData dataWithContentsOfURL:url];
        NSArray *result = [MangafoxFetcher parseFetchResult:htmlData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.mangas = result;
        });
    });
    
    return nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self fetchMangas];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
