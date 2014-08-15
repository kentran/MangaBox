//
//  MangaListTVC.m
//  MangaBox
//
//  Created by Ken Tran on 2/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "ParsedMangasTVC.h"
#import "MangaSummaryViewController.h"

@interface ParsedMangasTVC () <UIAlertViewDelegate>

@end

@implementation ParsedMangasTVC

- (void)setMangas:(NSArray *)mangas
{
    _mangas = mangas;
    [self.tableView reloadData];
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
    
    cell.backgroundColor = UIColorFromRGB(0x121314);
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id detail = self.splitViewController.viewControllers[1];

    if ([detail isKindOfClass:[UINavigationController class]])
    {
        detail = [((UINavigationController *)detail).viewControllers firstObject];
    }
    if ([detail isKindOfClass:[MangaSummaryViewController class]])
    {
        [self prepareMangaDetailsViewController:detail toDisplayManga:self.mangas[indexPath.row]];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:parsedMangaSelected
                                                        object:self
                                                      userInfo:self.mangas[indexPath.row]];
}

#pragma mark - Navigation

- (void)prepareMangaDetailsViewController:(MangaSummaryViewController *)mvc toDisplayManga:(NSDictionary *)manga
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
            if ([segue.destinationViewController isKindOfClass:[MangaSummaryViewController class]]) {
                [self prepareMangaDetailsViewController:segue.destinationViewController
                                  toDisplayManga:self.mangas[indexPath.row]];
                
            }
        }
    }
}

#pragma mark - Alerts

- (void)alert:(NSString *)msg
{
    [[[UIAlertView alloc] initWithTitle:@"Error"
                                message:msg
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
}

- (void)fatalAlert:(NSString *)msg
{
    [[[UIAlertView alloc] initWithTitle:@"Error"
                                message:msg
                               delegate:self
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
