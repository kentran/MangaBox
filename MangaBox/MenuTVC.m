//
//  MenuTVC.m
//  MangaBox
//
//  Created by Ken Tran on 6/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "MenuTVC.h"
#import "AdvancedSearchViewController.h"
#import "SearchedMangaViewController.h"
#import "MangaSummaryViewController.h"
#import "MangasCDTVC.h"
#import "MangaDictionaryDefinition.h"
#import "MangaBoxNotification.h"
#import "Manga+Create.h"

@interface MenuTVC ()
@property (nonatomic, strong) NSDictionary *criteria;
@property (nonatomic, strong) NSDictionary *newMangaInfo;
@end

@implementation MenuTVC

- (NSDictionary *)newMangaInfo {
    if (!_newMangaInfo) _newMangaInfo = [[NSDictionary alloc] init];
    return _newMangaInfo;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 2;
}

#pragma mark - Table view selection

// -------------------------------------------------------------------------------
//	tableView:didSelectRowAtIndexPath:
// -------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Get a reference to the DetailViewManager.
    // DetailViewManager is the delegate of our split view.
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];

    if ([cell.textLabel.text isEqualToString:@"Advanced Search"]) {
//        // Create and configure a new detail view controller appropriate for the selection.
//        UIViewController <SubstitutableDetailViewController> *detailViewController = nil;
//        
//        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:[NSBundle mainBundle]];
//        AdvancedSearchVC *newDetailViewController = [sb instantiateViewControllerWithIdentifier:@"Advanced Search Detail View"];
//        
//        newDetailViewController.delegate = self;
//        detailViewController = newDetailViewController;
//        
//        detailViewController.title = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
//        
//        // DetailViewManager exposes a property, detailViewController.  Set this property
//        // to the detail view controller we want displayed.  Configuring the detail view
//        // controller to display the navigation button (if needed) and presenting it
//        // happens inside DetailViewManager.
//        detailViewManager.detailViewController = detailViewController;
    }
    else {
        
    }
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.destinationViewController isKindOfClass:[SearchedMangaViewController class]]) {
        SearchedMangaViewController *smvc = (SearchedMangaViewController *)segue.destinationViewController;
        smvc.criteria = self.criteria;
    } else if ([segue.destinationViewController isKindOfClass:[MangasCDTVC class]]) {
        MangasCDTVC *mcdtvc = (MangasCDTVC *)segue.destinationViewController;
        mcdtvc.managedObjectContext = self.managedObjectContext;
        mcdtvc.addedMangaDictionary = self.newMangaInfo;
    } else if ([segue.destinationViewController isKindOfClass:[AdvancedSearchViewController class]]) {
        
    }
}

#pragma mark - Observer

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(prepareToAddNewManga:)
                                                 name:addingNewMangaToCollectionNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(prepareViewForSearchResult:)
                                                 name:startAdvancedSearchNotification
                                               object:nil];
}

- (void)prepareToAddNewManga:(NSNotification *)notification
{
    self.newMangaInfo = notification.userInfo;

    // Avoid nested pushing segue by calling search or add continuously
    // Pop the current Manga List before pushing the updated one
    if ([self.navigationController.viewControllers count] > 1)
        [self.navigationController popToRootViewControllerAnimated:NO];
    
    [self performSegueWithIdentifier:@"Show Collection" sender:self];
}

- (void)prepareViewForSearchResult:(NSNotification *)notification
{
    self.criteria = notification.userInfo;

    // Avoid nested pushing segue by calling search or add continuously
    // Pop the current Manga List before pushing the updated one
    if ([[self.navigationController.viewControllers lastObject] isKindOfClass:[SearchedMangaViewController class]])
        [self.navigationController popToRootViewControllerAnimated:NO];
    
    [self performSegueWithIdentifier:@"Show Searched Mangas" sender:self];
}


@end
