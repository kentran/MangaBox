//
//  DownloadTasksTVC.m
//  MangaBox
//
//  Created by Ken Tran on 19/4/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "DownloadTasksTVC.h"
#import "DownloadManager.h"
#import "Chapter.h"
#import "MangaDictionaryDefinition.h"
#import "MangaBoxNotification.h"

@interface DownloadTasksTVC ()
@property (nonatomic, strong) DownloadManager *downloadManager;
@property (nonatomic, strong) NSMutableArray *tasks;
@end

@implementation DownloadTasksTVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserverForName:finishDownloadChapterPage
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      [self.tableView reloadData];
                                                  }];
}

- (DownloadManager *)downloadManager
{
    if (!_downloadManager) _downloadManager = [DownloadManager sharedManager];
    return _downloadManager;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) return [self.downloadManager.downloadingChapters count];
    else if (section == 1) return [self.downloadManager.queueingChapters count];
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) return @"Downloading Chapters";
    else if (section == 1) return @"Chapters In Queue";
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Download Task" forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        if (indexPath.row < [self.downloadManager.downloadingChapters count]) {
            Chapter *chapter = self.downloadManager.downloadingChapters[indexPath.row];
            cell.textLabel.text = chapter.name;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Downloading... %lu/%@", (unsigned long)[chapter.pages count], chapter.pagesCount];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row < [self.downloadManager.queueingChapters count]) {
            Chapter *chapter = self.downloadManager.queueingChapters[indexPath.row];
            cell.textLabel.text = chapter.name;
            cell.detailTextLabel.text = @"Waiting...";
        }
    }
    
    return cell;
}

@end
