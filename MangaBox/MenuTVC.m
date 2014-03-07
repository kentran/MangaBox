//
//  MenuTVC.m
//  MangaBox
//
//  Created by Ken Tran on 6/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "MenuTVC.h"
#import "DetailViewManager.h"
#import "AdvancedSearchVC.h"
#import "SearchedMangaViewController.h"
#import "MangaDetailsViewController.h"

@interface MenuTVC () <AdvancedSearchVCDelegate>
@property (nonatomic, strong) NSDictionary *criteria;
@end

@implementation MenuTVC

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Menu Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    if (cell == Nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    
    // Set appropriate labels for the cells.
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Advanced Search";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.row == 1) {
//        cell.textLabel.text = @"Detail View Controller One";
//        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view selection

// -------------------------------------------------------------------------------
//	tableView:didSelectRowAtIndexPath:
// -------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Get a reference to the DetailViewManager.
    // DetailViewManager is the delegate of our split view.
    DetailViewManager *detailViewManager = (DetailViewManager *)self.splitViewController.delegate;
    
    NSUInteger row = indexPath.row;
    
    if (row == 1) {
//        AdvancedSearchVC *newTableViewController = [[Advanced alloc] init];
//        [self.navigationController pushViewController:newTableViewController animated:YES];
//        
//        [newTableViewController release];
    }
    else {
        // Create and configure a new detail view controller appropriate for the selection.
        UIViewController <SubstitutableDetailViewController> *detailViewController = nil;
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:[NSBundle mainBundle]];
        AdvancedSearchVC *newDetailViewController = [sb instantiateViewControllerWithIdentifier:@"Advanced Search Detail View"];
        
        newDetailViewController.delegate = self;
        detailViewController = newDetailViewController;
        
        detailViewController.title = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;

        // DetailViewManager exposes a property, detailViewController.  Set this property
        // to the detail view controller we want displayed.  Configuring the detail view
        // controller to display the navigation button (if needed) and presenting it
        // happens inside DetailViewManager.
        detailViewManager.detailViewController = detailViewController;
    }
}

#pragma mark - AdvancedSearchVCDelegate

- (void)advancedSearchVC:(AdvancedSearchVC *)vc selectedParams:(NSDictionary *)params
{
    self.criteria = params;
    
    // Avoid nested pushing segue by calling search continuously
    // Pop the current Manga List before pushing the updated one
    if ([self.navigationController.viewControllers count] > 1)
        [self.navigationController popToRootViewControllerAnimated:NO];
    
    [self performSegueWithIdentifier:@"Display Manga List" sender:self];
}


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.destinationViewController isKindOfClass:[SearchedMangaViewController class]]) {
        SearchedMangaViewController *smvc = segue.destinationViewController;
        smvc.criteria = self.criteria;
    }
}



@end
