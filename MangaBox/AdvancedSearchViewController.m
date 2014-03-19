//
//  AdvancedSearchVC.m
//  MangaBox
//
//  Created by Ken Tran on 6/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "AdvancedSearchViewController.h"
#import "SearchedMangaViewController.h"
#import "MangaBoxNotification.h"

@interface AdvancedSearchViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *seriesNameField;
@property (weak, nonatomic) IBOutlet UITextField *authorNameField;
@property (weak, nonatomic) IBOutlet UITextField *artistNameField;
@property (weak, nonatomic) IBOutlet UIButton *sortByButton;
@property (weak, nonatomic) IBOutlet UIButton *sortOrderButton;
@property (weak, nonatomic) IBOutlet UIButton *seriesCompletionButton;
@property (strong, nonatomic) NSMutableDictionary *genres;
@property (strong, nonatomic) NSMutableDictionary *params;

@property (nonatomic) double lastRequestTimestamp;
@end

@implementation AdvancedSearchViewController

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (NSMutableDictionary *)genres
{
    if (!_genres) {
        _genres = [[NSMutableDictionary alloc] init];
        [_genres setValuesForKeysWithDictionary:@{
              @"Action":@"0", @"Adult":@"0", @"Adventure":@"0", @"Comedy":@"0", @"Doujinshi":@"0",
              @"Drama":@"0", @"Ecchi":@"0", @"Fantasy":@"0", @"Gender Bender":@"0", @"Harem":@"0",
              @"Historical":@"0", @"Horror":@"0", @"Josei":@"0", @"Martial Arts":@"0", @"Mature":@"0",
              @"Mecha":@"0", @"Mystery":@"0", @"One Shot":@"0", @"Psychological":@"0", @"Romance":@"0",
              @"School Life":@"0", @"Sci-fi":@"0", @"Seinen":@"0", @"Shoujo":@"0", @"Shoujo Ai":@"0",
              @"Shounen":@"0", @"Shounen Ai":@"0", @"Slice of Life":@"0", @"Smut":@"0", @"Sports":@"0",
              @"Supernatural":@"0", @"Tragedy":@"0", @"Webtoons":@"0", @"Yaoi":@"0", @"Yuri":@"0"
           }];
    }
    
    return _genres;
}

- (NSMutableDictionary *)params
{
    if (!_params) _params = [[NSMutableDictionary alloc] init];
    return _params;
}

#define SEARCH_DELAY_SEC 5

- (IBAction)searchButtonTouch:(UIBarButtonItem *)sender
{
    [self prepareSearchCriteria];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:startAdvancedSearchNotification
                                                        object:self
                                                      userInfo:self.params];
}

- (void)prepareSearchCriteria
{
    double fetchTimestamp;
    if (!self.lastRequestTimestamp) {
        // start search the first time after the controller is loaded
        self.lastRequestTimestamp = [[NSDate date] timeIntervalSince1970];
        fetchTimestamp = self.lastRequestTimestamp;
    } else {
        // start search multiple time consecutively
        double now = [[NSDate date] timeIntervalSince1970];
        if (now > (self.lastRequestTimestamp + SEARCH_DELAY_SEC)) {
            fetchTimestamp = now;
        } else {
            fetchTimestamp = self.lastRequestTimestamp + SEARCH_DELAY_SEC;
        }
        self.lastRequestTimestamp = fetchTimestamp;
    }
    
    [self.params setValuesForKeysWithDictionary: @{
                                                   @"fetchTimestamp": [NSString stringWithFormat:@"%f", fetchTimestamp],
                                                   @"name": self.seriesNameField.text,
                                                   @"author": self.authorNameField.text,
                                                   @"artist": self.artistNameField.text,
                                                   @"genres": self.genres,
                                                   @"sortBy": self.sortByButton.currentTitle,
                                                   @"sortOrder": self.sortOrderButton.currentTitle,
                                                   @"isCompleted": self.seriesCompletionButton.currentTitle,
                                                   @"page": @"1"
                                                   }];
}


//- (IBAction)startSearch:(UIButton *)sender {
//    double fetchTimestamp;
//    if (!self.lastRequestTimestamp) {
//        // start search the first time after the controller is loaded
//        self.lastRequestTimestamp = [[NSDate date] timeIntervalSince1970];
//        fetchTimestamp = self.lastRequestTimestamp;
//    } else {
//        // start search multiple time consecutively
//        double now = [[NSDate date] timeIntervalSince1970];
//        if (now > (self.lastRequestTimestamp + SEARCH_DELAY_SEC)) {
//            fetchTimestamp = now;
//        } else {
//            fetchTimestamp = self.lastRequestTimestamp + SEARCH_DELAY_SEC;
//        }
//        self.lastRequestTimestamp = fetchTimestamp;
//    }
//    
//    [self.params setValuesForKeysWithDictionary: @{
//        @"fetchTimestamp": [NSString stringWithFormat:@"%f", fetchTimestamp],
//        @"name": self.seriesNameField.text,
//        @"author": self.authorNameField.text,
//        @"artist": self.artistNameField.text,
//        @"genres": self.genres,
//        @"sortBy": self.sortByButton.currentTitle,
//        @"sortOrder": self.sortOrderButton.currentTitle,
//        @"isCompleted": self.seriesCompletionButton.currentTitle,
//        @"page": @"1"
//    }];
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:startAdvancedSearchNotification
//                                                        object:self
//                                                      userInfo:self.params];
//}


- (IBAction)genresButtonTouch:(UIButton *)sender {
    NSString *touchedGenre = sender.currentTitle;
    NSLog(@"%@", [self.genres objectForKey:touchedGenre]);
    if ([[self.genres valueForKey:touchedGenre] isEqualToString:@"0"]) {
        [self.genres setObject:@"1" forKey:touchedGenre];
        [sender setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    } else if ([[self.genres valueForKey:touchedGenre] isEqualToString:@"1"]) {
        [self.genres setObject:@"2" forKey:touchedGenre];
        [sender setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    } else {
        [self.genres setObject:@"0" forKey:touchedGenre];
        [sender setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    }
}

- (IBAction)sortByButtonTouch:(UIButton *)sender {
    if ([sender.currentTitle isEqualToString:@"Name"]) {
        [sender setTitle:@"Views" forState:UIControlStateNormal];
    } else if ([sender.currentTitle isEqualToString:@"Views"]) {
        [sender setTitle:@"Chapters" forState:UIControlStateNormal];
    } else if ([sender.currentTitle isEqualToString:@"Chapters"]) {
        [sender setTitle:@"Latest Chapter" forState:UIControlStateNormal];
    } else {
        [sender setTitle:@"Name" forState:UIControlStateNormal];
    }
}

- (IBAction)sortOrderButtonTouch:(UIButton *)sender {
    if ([sender.currentTitle isEqualToString:@"ASC"]) {
        [sender setTitle:@"DESC" forState:UIControlStateNormal];
    } else {
        [sender setTitle:@"ASC" forState:UIControlStateNormal];
    }
}

- (IBAction)seriesCompletionButtonTouch:(UIButton *)sender {
    if ([sender.currentTitle isEqualToString:@"Completed and Ongoing"]) {
        [sender setTitle:@"Completed" forState:UIControlStateNormal];
    } else if ([sender.currentTitle isEqualToString:@"Completed"]) {
        [sender setTitle:@"Ongoing" forState:UIControlStateNormal];
    } else {
        [sender setTitle:@"Completed and Ongoing" forState:UIControlStateNormal];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[SearchedMangaViewController class]]) {
        [self prepareSearchCriteria];
        SearchedMangaViewController *smvc = segue.destinationViewController;
        smvc.criteria = self.params;
    }
}

@end
