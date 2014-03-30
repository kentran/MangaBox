//
//  AdvancedSearchTVC.m
//  MangaBox
//
//  Created by Ken Tran on 30/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "AdvancedSearchTVC.h"
#import "SearchedMangaViewController.h"

@interface AdvancedSearchTVC () <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *seriesNameField;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UILabel *statusText;
@property (weak, nonatomic) IBOutlet UILabel *sortText;

@property (nonatomic, strong) NSArray *sortBy;
@property (nonatomic, strong) NSArray *sortOrder;
@property (nonatomic, strong) NSArray *completionStatus;

@property (nonatomic, strong) NSArray *genres;      // will be initialized according to manga source
@property (strong, nonatomic) NSMutableDictionary *genresDictionary;
@property (strong, nonatomic) NSMutableDictionary *params;

@property (nonatomic) double lastRequestTimestamp;
@end

@implementation AdvancedSearchTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.sortBy = @[@"Name", @"Chapters", @"Views", @"Latest Update"];
    self.sortOrder = @[@"ASC", @"DESC"];
    self.completionStatus = @[@"Both", @"Completed", @"Ongoing"];
    
    self.statusText.text = self.completionStatus[[self.pickerView selectedRowInComponent:0]];
    NSString *selectedSort = self.sortBy[[self.pickerView selectedRowInComponent:1]];
    NSString *selectedOrder = self.sortOrder[[self.pickerView selectedRowInComponent:2]];
    self.sortText.text = [NSString stringWithFormat:@"%@ - %@", selectedSort, selectedOrder];
    
    [self.tableView reloadData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Properties

- (NSArray *)genres
{
    if (!_genres) {
        _genres = @[@"Action", @"Adult", @"Adventure", @"Comedy", @"Doujinshi",
                    @"Drama", @"Ecchi", @"Fantasy", @"Gender Bender", @"Harem",
                    @"Historical", @"Horror", @"Josei", @"Martial Arts", @"Mature",
                    @"Mecha", @"Mystery", @"One Shot", @"Psychological", @"Romance",
                    @"School Life", @"Sci-fi", @"Seinen", @"Shoujo", @"Shoujo Ai",
                    @"Shounen", @"Shounen Ai", @"Slice of Life", @"Smut", @"Sports",
                    @"Supernatural", @"Tragedy", @"Webtoons", @"Yaoi", @"Yuri"];
    }
    return _genres;
}

- (NSMutableDictionary *)genresDictionary
{
    if (!_genresDictionary) {
        _genresDictionary = [[NSMutableDictionary alloc] init];
        for (NSString *genre in self.genres ) {
            [_genresDictionary setObject:@"0" forKey:genre];
        }
    }
    
    return _genresDictionary;
}

- (NSMutableDictionary *)params
{
    if (!_params) _params = [[NSMutableDictionary alloc] init];
    return _params;
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return [self.completionStatus count];
            break;
          
        case 1:
            return [self.sortBy count];
            break;
            
        case 2:
            return [self.sortOrder count];
            break;
    }
    return 0;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            self.statusText.text = self.completionStatus[row];
            break;
            
        case 1:
            self.sortText.text = [NSString stringWithFormat:@"%@ - %@", self.sortBy[row], self.sortOrder[[pickerView selectedRowInComponent:2]]];
            break;
            
        case 2:
            self.sortText.text = [NSString stringWithFormat:@"%@ - %@", self.sortBy[[pickerView selectedRowInComponent:1]], self.sortOrder[row]];
            break;
    }
}

#pragma mark - UIPickerViewDelegate

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *pView = (UILabel *)view;
    if (!pView) {
        pView = [[UILabel alloc] init];
        if (component == 0) {
            pView.text = self.completionStatus[row];
        } else if (component == 1) {
            pView.text = self.sortBy[row];
        } else {
            pView.text = self.sortOrder[row];
        }
        pView.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
    }
    return pView;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 24;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.genres count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Genres";
}

#define GENRE_TAG 1
#define MARK_IMAGE_TAG 2

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Genre Cell" forIndexPath:indexPath];
    
    UILabel *genreLabel = (UILabel *)[cell.contentView viewWithTag:GENRE_TAG];
    NSString *genre = self.genres[indexPath.row];
    genreLabel.text = genre;
    
    UIImageView *markImageView = (UIImageView *)[cell.contentView viewWithTag:MARK_IMAGE_TAG];
    if ([[self.genresDictionary objectForKey:genre] isEqualToString:@"0"]) {
        markImageView.image = [UIImage imageNamed:@"emptyMark"];
    } else if ([[self.genresDictionary objectForKey:genre] isEqualToString:@"1"]) {
        markImageView.image = [UIImage imageNamed:@"checkMark"];
    } else {
        markImageView.image = [UIImage imageNamed:@"crossMark"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    UILabel *genreLabel = (UILabel *)[cell.contentView viewWithTag:GENRE_TAG];
    NSString *genre = genreLabel.text;
    
    UIImageView *markImageView = (UIImageView *)[cell.contentView viewWithTag:MARK_IMAGE_TAG];
    
    if ([[self.genresDictionary objectForKey:genre] isEqualToString:@"0"]) {
        [self.genresDictionary setObject:@"1" forKey:genre];
        markImageView.image = [UIImage imageNamed:@"checkMark"];
    } else if ([[self.genresDictionary objectForKey:genre] isEqualToString:@"1"]) {
        [self.genresDictionary setObject:@"2" forKey:genre];
        markImageView.image = [UIImage imageNamed:@"crossMark"];
    } else {
        [self.genresDictionary setObject:@"0" forKey:genre];
        markImageView.image = [UIImage imageNamed:@"emptyMark"];
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[SearchedMangaViewController class]]) {
        [self prepareSearchCriteria];
        SearchedMangaViewController *smvc = segue.destinationViewController;
        smvc.criteria = self.params;
    }
}

#define SEARCH_DELAY_SEC 5

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
       @"author": @"",
       @"artist": @"",
       @"genres": self.genresDictionary,
       @"sortBy": self.sortBy[[self.pickerView selectedRowInComponent:1]],
       @"sortOrder": self.sortOrder[[self.pickerView selectedRowInComponent:2]],
       @"isCompleted": self.completionStatus[[self.pickerView selectedRowInComponent:0]],
       @"page": @"1"
    }];
}


@end
