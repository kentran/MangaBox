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

@interface DownloadTasksTVC ()
@property (nonatomic, strong) DownloadManager *downloadManager;
@property (nonatomic, strong) NSMutableArray *tasks;
@end

@implementation DownloadTasksTVC

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Download Task Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

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

#define TITLE_LABEL_TAG 1
#define PAGES_LABEL_TAG 2
#define PROGRESS_BAR_TAG 3

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Download Task" forIndexPath:indexPath];
    
    UILabel *title = (UILabel *)[cell.contentView viewWithTag:TITLE_LABEL_TAG];
    UILabel *pages = (UILabel *)[cell.contentView viewWithTag:PAGES_LABEL_TAG];
    UIProgressView *progressBar = (UIProgressView *)[cell.contentView viewWithTag:PROGRESS_BAR_TAG];
    
    if (indexPath.section == 0) {
        if (indexPath.row < [self.downloadManager.downloadingChapters count]) {
            Chapter *chapter = self.downloadManager.downloadingChapters[indexPath.row];
            title.text = chapter.name;
            pages.text = [NSString stringWithFormat:@"Downloading... %lu/%@", (unsigned long)[chapter.pages count], chapter.pagesCount];
            
            progressBar.hidden = NO;
            if ([chapter.pagesCount doubleValue]) {
                progressBar.progress = [chapter.pages count] / [chapter.pagesCount doubleValue];
            } else {
                progressBar.progress = 0.0;
            }
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row < [self.downloadManager.queueingChapters count]) {
            Chapter *chapter = self.downloadManager.queueingChapters[indexPath.row];
            title.text = chapter.name;
            pages.text = @"Waiting...";
            progressBar.hidden = YES;
        }
    }
    
    cell.backgroundColor = UIColorFromRGB(0x121314);
    
    return cell;
}

@end
