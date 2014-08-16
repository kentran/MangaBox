//
//  AdvancedSearchTVC.m
//  MangaBox
//
//  Created by Ken Tran on 30/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "AdvancedSearchTVC.h"
#import "SearchedMangaViewController.h"
#import "SearchResultSplitViewController.h"

@interface AdvancedSearchTVC () <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *criteriaView;
@property (weak, nonatomic) IBOutlet UITextField *seriesNameField;


@property (weak, nonatomic) IBOutlet UIView *orderView;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;


@property (weak, nonatomic) IBOutlet UILabel *statusText;
@property (weak, nonatomic) IBOutlet UILabel *sortText;

@property (weak, nonatomic) IBOutlet UIView *completedMangaView;
@property (weak, nonatomic) IBOutlet UILabel *completedIndicatorLabel;
@property (weak, nonatomic) IBOutlet UILabel *completedLabel;



@property (weak, nonatomic) IBOutlet UIView *ongoingMangaView;
@property (weak, nonatomic) IBOutlet UILabel *ongoingIndicatorLabel;
@property (weak, nonatomic) IBOutlet UILabel *ongoingLabel;

@property (nonatomic, strong) NSArray *sortBy;
@property (nonatomic, strong) NSArray *sortOrder;
@property (nonatomic, strong) NSArray *completionStatus;

@property (nonatomic, strong) NSArray *genres;      // will be initialized according to manga source
@property (strong, nonatomic) NSMutableDictionary *genresDictionary;
@property (strong, nonatomic) NSMutableDictionary *params;

@property (nonatomic) double lastRequestTimestamp;
@end

@implementation AdvancedSearchTVC

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Advanced Search Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Make search text field clearer
    self.seriesNameField.borderStyle = UITextBorderStyleRoundedRect;
    
    // Completion status view
    self.completedMangaView.layer.cornerRadius = 8.0f;
    self.ongoingMangaView.layer.cornerRadius = 8.0f;
    
    /* By default, make the both status as selected */
    self.ongoingMangaView.backgroundColor = STATUS_SELECTED_BORDER_BACKGROUND_COLOR;
    self.ongoingLabel.backgroundColor = STATUS_SELECTED_LABEL_BACKGROUND_COLOR;
    self.ongoingLabel.textColor = [UIColor whiteColor];
    self.ongoingIndicatorLabel.backgroundColor = STATUS_SELECTED_LABEL_BACKGROUND_COLOR;
    self.ongoingIndicatorLabel.text = STATUS_SELECTED;
    self.ongoingIndicatorLabel.textColor = [UIColor whiteColor];
    
    self.completedMangaView.backgroundColor = STATUS_SELECTED_BORDER_BACKGROUND_COLOR;
    self.completedLabel.backgroundColor = STATUS_SELECTED_LABEL_BACKGROUND_COLOR;
    self.completedLabel.textColor = [UIColor whiteColor];
    self.completedIndicatorLabel.backgroundColor = STATUS_SELECTED_LABEL_BACKGROUND_COLOR;
    self.completedIndicatorLabel.text = STATUS_SELECTED;
    self.completedIndicatorLabel.textColor = [UIColor whiteColor];
    
    /* Order view layout */
    //self.orderView.layer.borderWidth = 1;
    //self.orderView.layer.borderColor = UIColorFromRGB(0xbfbfbf).CGColor;
    self.orderView.layer.cornerRadius = 8.0f;
    self.orderView.layer.masksToBounds = NO;
    self.orderView.layer.shadowOpacity = 0.1;
    self.orderView.layer.shadowRadius = 2;
    
    /* Initialize value for ordering */
    self.sortBy = @[@"Name", @"Chapters", @"Views", @"Latest Update"];
    self.sortOrder = @[@"ASC", @"DESC"];
    self.completionStatus = @[@"Both", @"Completed", @"Ongoing"];
    
    NSString *selectedSort = self.sortBy[[self.pickerView selectedRowInComponent:0]];
    NSString *selectedOrder = self.sortOrder[[self.pickerView selectedRowInComponent:1]];
    self.sortText.text = [NSString stringWithFormat:@"%@ - %@", selectedSort, selectedOrder];
    
    [self.tableView reloadData];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [Tracker trackAdvancedSearchWithAction:@"Series Name" label:textField.text];
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
//        _genres = @[@"Action", @"Adventure", @"Comedy", @"Doujinshi",
//                    @"Drama", @"Fantasy", @"Harem",
//                    @"Historical", @"Horror", @"Josei", @"Martial Arts",
//                    @"Mecha", @"Mystery", @"One Shot", @"Psychological", @"Romance",
//                    @"School Life", @"Sci-fi", @"Seinen", @"Shoujo", @"Shoujo Ai",
//                    @"Shounen", @"Shounen Ai", @"Slice of Life", @"Smut", @"Sports",
//                    @"Supernatural", @"Tragedy", @"Webtoons", @"Yaoi", @"Yuri"];

        
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
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return [self.sortBy count];
            break;
            
        case 1:
            return [self.sortOrder count];
            break;
    }
    return 0;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            self.sortText.text = [NSString stringWithFormat:@"%@ - %@", self.sortBy[row], self.sortOrder[[pickerView selectedRowInComponent:1]]];
            [Tracker trackAdvancedSearchWithAction:@"Sort results" label:self.sortText.text];
            break;
            
        case 1:
            self.sortText.text = [NSString stringWithFormat:@"%@ - %@", self.sortBy[[pickerView selectedRowInComponent:0]], self.sortOrder[row]];
            [Tracker trackAdvancedSearchWithAction:@"Sort results" label:self.sortText.text];
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
            pView.text = self.sortBy[row];
        } else {
            pView.text = self.sortOrder[row];
        }
        pView.font = [UIFont systemFontOfSize:17.0f];
        pView.textColor = [UIColor whiteColor];
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
        
        [Tracker trackAdvancedSearchWithAction:@"With Genres" label:genre];
    } else if ([[self.genresDictionary objectForKey:genre] isEqualToString:@"1"]) {
        [self.genresDictionary setObject:@"2" forKey:genre];
        markImageView.image = [UIImage imageNamed:@"crossMark"];
        
        [Tracker trackAdvancedSearchWithAction:@"Without Genres" label:genre];
    } else {
        [self.genresDictionary setObject:@"0" forKey:genre];
        markImageView.image = [UIImage imageNamed:@"emptyMark"];
        
        [Tracker trackAdvancedSearchWithAction:@"Deselect Genres" label:genre];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[SearchedMangaViewController class]]) {
        [self prepareSearchCriteria];
        SearchedMangaViewController *smvc = (SearchedMangaViewController *)segue.destinationViewController;
        smvc.criteria = self.params;
    } else if ([segue.destinationViewController isKindOfClass:[SearchResultSplitViewController class]]) {
        [self prepareSearchCriteria];
        SearchResultSplitViewController *srsvc = (SearchResultSplitViewController *)segue.destinationViewController;
        srsvc.criteria= self.params;
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
    
    NSString *completionStatus;
    if ([self.completedIndicatorLabel.text isEqualToString:STATUS_SELECTED]
        && [self.ongoingIndicatorLabel.text isEqualToString:STATUS_SELECTED]) {
        completionStatus = @"Both";
    } else if ([self.completedIndicatorLabel.text isEqualToString:STATUS_SELECTED]) {
        completionStatus = @"Completed";
    } else if ([self.ongoingIndicatorLabel.text isEqualToString:STATUS_SELECTED]) {
        completionStatus = @"Ongoing";
    } else {
        completionStatus = @"";
    }
    
    [self.params setValuesForKeysWithDictionary: @{
       @"fetchTimestamp": [NSString stringWithFormat:@"%f", fetchTimestamp],
       @"name": self.seriesNameField.text,
       @"author": @"",
       @"artist": @"",
       @"genres": self.genresDictionary,
       @"sortBy": self.sortBy[[self.pickerView selectedRowInComponent:0]],
       @"sortOrder": self.sortOrder[[self.pickerView selectedRowInComponent:1]],
       @"isCompleted": completionStatus,
       @"page": @"1"
    }];
}

#pragma mark - IBAction

- (IBAction)completedToggle:(UITapGestureRecognizer *)sender
{
    if ([self.completedIndicatorLabel.text isEqualToString:STATUS_SELECTED]) {
        /* Change to deselected status */
        self.completedMangaView.backgroundColor = STATUS_DESELECTED_BORDER_BACKGROUND_COLOR;
        self.completedLabel.backgroundColor = STATUS_DESELECTED_LABEL_BACKGROUND_COLOR;
        self.completedLabel.textColor = [UIColor darkGrayColor];
        self.completedIndicatorLabel.backgroundColor = STATUS_DESELECTED_LABEL_BACKGROUND_COLOR;
        self.completedIndicatorLabel.text = STATUS_DESELECTED;
        self.completedIndicatorLabel.textColor = [UIColor darkGrayColor];
    } else {
        /* Change to selected status */
        self.completedMangaView.backgroundColor = STATUS_SELECTED_BORDER_BACKGROUND_COLOR;
        self.completedLabel.backgroundColor = STATUS_SELECTED_LABEL_BACKGROUND_COLOR;
        self.completedLabel.textColor = [UIColor whiteColor];
        self.completedIndicatorLabel.backgroundColor = STATUS_SELECTED_LABEL_BACKGROUND_COLOR;
        self.completedIndicatorLabel.text = STATUS_SELECTED;
        self.completedIndicatorLabel.textColor = [UIColor whiteColor];
    }
    
    [Tracker trackAdvancedSearchWithAction:@"Completed Toggle" label:self.completedIndicatorLabel.text];
}

- (IBAction)ongoingToggle:(UITapGestureRecognizer *)sender
{
    if ([self.ongoingIndicatorLabel.text isEqualToString:STATUS_SELECTED]) {
        /* Change to deselected status */
        self.ongoingMangaView.backgroundColor = STATUS_DESELECTED_BORDER_BACKGROUND_COLOR;
        self.ongoingLabel.backgroundColor = STATUS_DESELECTED_LABEL_BACKGROUND_COLOR;
        self.ongoingLabel.textColor = [UIColor darkGrayColor];
        self.ongoingIndicatorLabel.backgroundColor = STATUS_DESELECTED_LABEL_BACKGROUND_COLOR;
        self.ongoingIndicatorLabel.text = STATUS_DESELECTED;
        self.ongoingIndicatorLabel.textColor = [UIColor darkGrayColor];
    } else {
        /* Change to selected status */
        self.ongoingMangaView.backgroundColor = STATUS_SELECTED_BORDER_BACKGROUND_COLOR;
        self.ongoingLabel.backgroundColor = STATUS_SELECTED_LABEL_BACKGROUND_COLOR;
        self.ongoingLabel.textColor = [UIColor whiteColor];
        self.ongoingIndicatorLabel.backgroundColor = STATUS_SELECTED_LABEL_BACKGROUND_COLOR;
        self.ongoingIndicatorLabel.text = STATUS_SELECTED;
        self.ongoingIndicatorLabel.textColor = [UIColor whiteColor];
    }
    
    [Tracker trackAdvancedSearchWithAction:@"Ongoing Toggle" label:self.ongoingIndicatorLabel.text];
}


@end
