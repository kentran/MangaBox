//
//  SearchResultSplitViewController.m
//  MangaBox
//
//  Created by Ken Tran on 15/4/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "SearchResultSplitViewController.h"
#import "SearchedMangaViewController.h"
#import "MangaSummaryViewController.h"
#import "AddMangaConfirmViewController.h"
#import "MangaBoxNotification.h"

@interface SearchResultSplitViewController ()
@property (nonatomic, strong) SearchedMangaViewController *searchedMangasVC;
@property (nonatomic, strong) MangaSummaryViewController *mangaSummaryVC;

@property (nonatomic, strong) NSURL *mangaURL;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;
@end

@implementation SearchResultSplitViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(prepareMangaSummaryVC:)
                                                 name:parsedMangaSelected
                                               object:nil];
}

- (void)prepareMangaSummaryVC:(NSNotification *)notification
{
    NSDictionary *manga = notification.userInfo;
    self.mangaSummaryVC.mangaURL = [NSURL URLWithString:[manga valueForKey:@"url"]];
    self.mangaSummaryVC.chaptersCount = [manga valueForKey:@"chaptersCount"];
    self.mangaSummaryVC.mangaUnique = [manga valueForKey:@"unique"];
    
    // Hold on to the value of the selected mangaURL
    self.mangaURL = [NSURL URLWithString:[manga valueForKey:@"url"]];
    
    // Enable the add button
    self.addButton.enabled = YES;
}

- (void)setCriteria:(NSDictionary *)criteria
{
    _criteria = criteria;
    self.searchedMangasVC.criteria = _criteria;
    [self.searchedMangasVC.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[SearchedMangaViewController class]]) {
        SearchedMangaViewController *smvc = (SearchedMangaViewController *)segue.destinationViewController;
        smvc.criteria = self.criteria;
        self.searchedMangasVC = smvc;
    } else if ([segue.destinationViewController isKindOfClass:[MangaSummaryViewController class]]) {
        MangaSummaryViewController *msvc = (MangaSummaryViewController *)segue.destinationViewController;
        self.mangaSummaryVC = msvc;
    } else if ([segue.destinationViewController isKindOfClass:[AddMangaConfirmViewController class]]) {
        AddMangaConfirmViewController *amcvc = (AddMangaConfirmViewController *)segue.destinationViewController;
        amcvc.mangaURL = self.mangaURL;
    }
}


@end
