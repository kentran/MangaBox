//
//  DownloadManager.m
//  MangaBox
//
//  Created by Ken Tran on 8/4/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "DownloadManager.h"
#import "Chapter+UpdateInfo.h"
#import "Page+Create.h"
#import "Page+Getter.h"
#import "MangaDictionaryDefinition.h"
#import "MangaFetcher.h"
#import "MangaBoxNotification.h"
#import "Manga.h"
#import "MangaBoxAppDelegate.h"

@interface DownloadManager()
@property (nonatomic, strong) NSMutableArray *downloadingChapters;
@property (nonatomic, strong) NSMutableArray *queueingChapters;
@end

@implementation DownloadManager

#pragma mark - Lazy instantiation

- (NSMutableArray *)downloadingChapters
{
    if (!_downloadingChapters) _downloadingChapters = [[NSMutableArray alloc] init];
    return _downloadingChapters;
}

- (NSMutableArray *)queueingChapters
{
    if (!_queueingChapters) _queueingChapters = [[NSMutableArray alloc] init];
    return  _queueingChapters;
}

#pragma mark - Shared Instance

+ (id)sharedManager
{
    static DownloadManager *sharedDownloadManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDownloadManager = [[self alloc] init];
    });
    return sharedDownloadManager;
}

- (id)init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(prepareNextChapter:)
                                                     name:finishDownloadChapter
                                                   object:nil];
    }
    return self;
}

#pragma mark - Manage queues

- (void)enqueueChapters:(NSArray *)chapters
{
    [self.queueingChapters addObjectsFromArray:chapters];
    [self startDownloadingQueue];
}

#pragma mark - Downloading Queue Task

#define CHAPTERS_PER_RUN 3

- (void)startDownloadingQueue
{
    for (int i = 0; i < CHAPTERS_PER_RUN; i++) {
        [self downloadNextChapter];
    }
}

- (void)downloadNextChapter
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.queueingChapters count]) {
            Chapter *chapter = self.queueingChapters[0];
            NSLog(@"Next chapter: %@", chapter.name);
            [self.queueingChapters removeObjectAtIndex:0];
            [self startDownloadingChapter:chapter];
        } else {
            // Done
            NSLog(@"Nothing more to download");
        }
    });
}

- (void)prepareNextChapter:(NSNotification *)notification
{
    [self downloadNextChapter];
}

#pragma mark - Download Tasks

- (void)stopAllDownloadingForManga:(Manga *)manga
{
    for (Chapter *chapter in [manga.chapters allObjects]) {
        [self stopDownloadingChapter:chapter];
    }
}

- (void)stopDownloadingChapter:(Chapter *)chapter
{
    [chapter updateDownloadStatus:CHAPTER_STOPPED_DOWNLOADING];
    [self.downloadingChapters removeObject:chapter];
}

- (void)finishDownloadingChapter:(Chapter *)chapter
{
    NSLog(@"Done");
    [chapter updateDownloadStatus:CHAPTER_DOWNLOADED];
    [self.downloadingChapters removeObject:chapter];
    
    // Create notification for finishing download chapter
    NSDictionary *userInfo = @{ MANGA_TITLE: chapter.whichManga.title };
    [[NSNotificationCenter defaultCenter] postNotificationName:finishDownloadChapter
                                                        object:self
                                                      userInfo:userInfo];
}

- (void)startDownloadingChapter:(Chapter *)chapter
{
    NSLog(@"START DOWNLOADING");
    // If the chapter has been downloading half way
    // continue from the last downloaded page
    NSURL *url;
    if ([chapter.pages count]) {
        NSInteger lastPageIdx = [chapter.pages count] - 1;
        Page *lastDownloadedPage = [Page pageOfChapter:chapter atIndex:lastPageIdx];
        url = [NSURL URLWithString:lastDownloadedPage.url];
    } else {
        url = [NSURL URLWithString:chapter.url];
    }
    
    [chapter updateDownloadStatus:CHAPTER_DOWNLOADING];
    [self.downloadingChapters addObject:chapter];
    [self downloadHtmlPage:url forChapter:chapter];
}


- (void)downloadHtmlPage:(NSURL *)pageHtmlURL forChapter:(Chapter *)chapter
{
    if ([chapter.downloadStatus isEqualToString:CHAPTER_DOWNLOADING]) {
        NSURLRequest *request = [NSURLRequest requestWithURL:pageHtmlURL];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        
        __weak DownloadManager *weakSelf = self;
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
            completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error) {
                if (!error) {
                    // Fetch info according to the source and parse to temporary variable
                    NSDictionary *pageDictionary = [MangaFetcher parseChapterPage:localfile ofChapterURLString:chapter.url];
                    
                    // Check if the page is downloaded correctly
                    if ([chapter.pagesCount intValue] != [chapter.pages count]
                        && ![pageDictionary objectForKey:PAGE_IMAGE_URL])
                    {
                        //[weakSelf alert:DOWNLOAD_ERROR];
                        [weakSelf stopDownloadingChapter:chapter];
                        [weakSelf performSelectorOnMainThread:@selector(alert:)
                                                   withObject:DOWNLOAD_ERROR
                                                waitUntilDone:NO];
                        return;
                    }
                    
                    
                    // Set the pagesCount in chapter if it is not already set
                    if (![chapter.pagesCount intValue] && [pageDictionary objectForKey:PAGES_COUNT]) {
                        chapter.pagesCount = [NSNumber numberWithInt:[[pageDictionary objectForKey:PAGES_COUNT] intValue]];
                        [(MangaBoxAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
                    }
                    
                    //NSLog(@"%@", pageDictionary);
                    NSLog(@"%lu", (unsigned long)[chapter.pages count]);
                    // start download the image if applicable
                    if ([pageDictionary objectForKey:PAGE_IMAGE_URL]) {
                        [weakSelf downloadPageImageWithPageHtmlDictionary:pageDictionary
                                                            ofPageHtmlURL:request.URL
                                                               forChapter:chapter];
                    }
                } else {
                    NSLog(@"Download Error");
                    //[weakSelf alert:DOWNLOAD_ERROR];
                    [weakSelf stopDownloadingChapter:chapter];
                    [weakSelf performSelectorOnMainThread:@selector(alert:)
                                               withObject:DOWNLOAD_ERROR
                                            waitUntilDone:NO];
                }
                [session invalidateAndCancel];
            }];
        [task resume];
    }
}

- (void)downloadPageImageWithPageHtmlDictionary:(NSDictionary *)pageHtmlDictionary
                                  ofPageHtmlURL:(NSURL *)pageHtmlURL
                                     forChapter:(Chapter *)chapter
{
    NSURL *imageURL = [NSURL URLWithString:[pageHtmlDictionary objectForKeyedSubscript:PAGE_IMAGE_URL]];
    NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    __weak DownloadManager *weakSelf = self;
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
        completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error) {
            if (!error) {
                NSData *imageData = [NSData dataWithContentsOfURL:localfile];
                if (!imageData) { // if error, update the download status and return
                    //[weakSelf alert:DOWNLOAD_ERROR];
                    [weakSelf stopDownloadingChapter:chapter];
                    [weakSelf performSelectorOnMainThread:@selector(alert:)
                                               withObject:DOWNLOAD_ERROR
                                            waitUntilDone:NO];
                    return;
                }
                
                UIImage *image = [UIImage imageWithData:imageData];
                NSDictionary *pageDictionary = @{PAGE_URL: [pageHtmlURL absoluteString],
                                                 PAGE_IMAGE_URL: [imageURL absoluteString],
                                                 PAGE_IMAGE_DATA: UIImageJPEGRepresentation(image, 1.0)
                                                 };
                
                // save the page into core data
                Page *newPage = [Page pageWithInfo:pageDictionary
                                         ofChapter:chapter
                            inManagedObjectContext:chapter.managedObjectContext];
                
                // update the chapter updated attribute
                newPage.whichChapter.updated = [NSDate date];
                
                // if all the pages of the chapter is downloaded, reset the downloadStatus
                // and post a notification
                if ([chapter.pagesCount intValue] == [chapter.pages count]) {
                    [weakSelf finishDownloadingChapter:chapter];
                }
                
                // Download the next HTML page if applicable
                if ([pageHtmlDictionary objectForKey:NEXT_PAGE_TO_PARSE]) {
                    [weakSelf downloadHtmlPage:[NSURL URLWithString:[pageHtmlDictionary objectForKey:NEXT_PAGE_TO_PARSE]]
                                    forChapter:chapter];
                }
            } else {
                // error
                NSLog(@"Download Error");
                [weakSelf stopDownloadingChapter:chapter];
                [weakSelf performSelectorOnMainThread:@selector(alert:)
                                           withObject:DOWNLOAD_ERROR
                                        waitUntilDone:NO];
                //[weakSelf alert:DOWNLOAD_ERROR];
            }
            [session invalidateAndCancel];
        }];
    [task resume];
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

@end
