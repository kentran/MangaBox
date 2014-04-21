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
@property (strong, nonatomic) NSMutableDictionary *nextPageCriteria;  // criteria to load next page
@property (strong, nonatomic) NSMutableArray *searchedMangas;         // keeps track of mangas of all pages before set TVC
@property (nonatomic) double lastFetchTimestamp;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@end

@implementation SearchedMangaViewController

- (NSMutableArray *)searchedMangas
{
    if (!_searchedMangas) _searchedMangas = [[NSMutableArray alloc] init];
    return _searchedMangas;
}

- (NSMutableDictionary *)nextPageCriteria
{
    if (!_nextPageCriteria) _nextPageCriteria = [[NSMutableDictionary alloc] initWithDictionary:self.criteria];
    return  _nextPageCriteria;
}

- (void)setCriteria:(NSDictionary *)criteria
{
    _criteria = criteria;
    [self.spinner startAnimating];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    self.searchedMangas = nil;
    [self.nextPageCriteria setValuesForKeysWithDictionary:_criteria];
    [self fetchMangas];
}

#define FETCH_INTERVAL_SEC 5

- (NSArray *) fetchMangas
{
    // Animating the activity indicator and networkActivityIndicator
    [self.spinner startAnimating];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSURL *url = [MangafoxFetcher urlForFetchingMangas:self.nextPageCriteria];
    dispatch_queue_t fetchQ = dispatch_queue_create("mangafox fetcher", NULL);
    
    // Calculate the delay before starting the fetch task
    double delayInSeconds;
    double now = [[NSDate date] timeIntervalSince1970];
    double requestedFetchTimestamp = [[self.nextPageCriteria objectForKey:@"fetchTimestamp"] doubleValue];
    
    if (requestedFetchTimestamp > now) {    // due to tap on search multiple times
        delayInSeconds = requestedFetchTimestamp - now;
    } else {
        // tap search once
        if (!self.lastFetchTimestamp) {     // very first fetch
            delayInSeconds = 0;
        } else {                            // fetch for load next page
            delayInSeconds = FETCH_INTERVAL_SEC - (now - self.lastFetchTimestamp);
            if (delayInSeconds < 0) delayInSeconds = 0;
        }
    }

    // Atempt to delay the search for at least 5s
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, fetchQ, ^(void){
        NSData *htmlData = [NSData dataWithContentsOfURL:url];
        self.lastFetchTimestamp = [[NSDate date] timeIntervalSince1970];
        NSArray *result = [MangafoxFetcher parseFetchResult:htmlData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![url isEqual:[MangafoxFetcher urlForFetchingMangas:self.nextPageCriteria]]) {
                return;
            }
            
            [self.spinner stopAnimating];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            if (!result) {
                // if the result can't be found, alert the user
                [self fatalAlert:@"Result is not available. You are not allow to search continuously within 5s"];
                return;
            } else {
                [self.searchedMangas addObjectsFromArray:result];   // add result to current list of mangas
                self.mangas = self.searchedMangas;                  // set and display in TVC
            }
            
            // update criteria to next page
            int nextPage = [[self.nextPageCriteria valueForKey:@"page"] intValue];
            if ([MangafoxFetcher nextMangaListPageAvailability:htmlData]) {
                nextPage++;
                [self.nextPageCriteria setValue:[NSString stringWithFormat:@"%d", nextPage] forKey:@"page"];
            } else {
                [self.nextPageCriteria setValue:@"0" forKey:@"page"];
            }
        });
    });
    
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // load more data if the last row is displayed and next page param is not 0
    if (indexPath.row == ([self.mangas count] - 1) && [[self.nextPageCriteria objectForKey:@"page"] intValue]) {
        [self fetchMangas]; // fetch next page, criteria is already updated
    }
}

@end
