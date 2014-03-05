//
//  MangaListTVC.m
//  MangaBox
//
//  Created by Ken Tran on 2/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "MangaListTVC.h"
#import "MangaDetailsViewController.h"

@interface MangaListTVC ()

@end

@implementation MangaListTVC

- (void)setMangas:(NSArray *)mangas
{
    _mangas = mangas;
    [self.tableView reloadData];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return [self.mangas count];
}

#define TITLE_TAG 1
#define CHAPTERS_TAG 2
#define VIEWS_TAG 3

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Manga Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    UILabel *title, *chapters, *views;
    
    NSDictionary *manga = self.mangas[indexPath.row];
    title = (UILabel *)[cell.contentView viewWithTag:TITLE_TAG];
    chapters = (UILabel *)[cell.contentView viewWithTag:CHAPTERS_TAG];
    views = (UILabel *)[cell.contentView viewWithTag:VIEWS_TAG];
    
    title.text = [manga valueForKey:@"title"];
    chapters.text = [NSString stringWithFormat:@"%@ chapters", [manga valueForKey:@"chaptersCount"]];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setGroupingSeparator:@","];

    // Put comma to big number
    NSNumber *viewsCount = [numberFormatter numberFromString:[manga valueForKey:@"views"]];
    views.text = [NSString stringWithFormat:@"%@ views", [numberFormatter stringFromNumber:viewsCount]];
    
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

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id detail = self.splitViewController.viewControllers[1];
    if ([detail isKindOfClass:[UINavigationController class]])
    {
        detail = [((UINavigationController *)detail).viewControllers firstObject];
    }
    if ([detail isKindOfClass:[MangaDetailsViewController class]])
    {
        [self prepareMangaDetailsViewController:detail toDisplayManga:self.mangas[indexPath.row]];
    }

}

#pragma mark - Navigation

- (void) prepareMangaDetailsViewController:(MangaDetailsViewController *)mvc toDisplayManga:(NSDictionary *)manga
{
    mvc.mangaURL = [NSURL URLWithString:[manga valueForKey:@"url"]];
    mvc.title = [manga valueForKey:@"title"];
    mvc.chaptersCount = [manga valueForKey:@"chaptersCount"];
    mvc.mangaUnique = [manga valueForKey:@"unique"];
}

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Display Manga"]) {
                if ([segue.destinationViewController isKindOfClass:[MangaDetailsViewController class]]) {
                    [self prepareMangaDetailsViewController:segue.destinationViewController
                                      toDisplayManga:self.mangas[indexPath.row]];
                    
                }
            }
        }
    }
}

@end
