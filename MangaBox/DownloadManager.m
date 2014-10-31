//
//  DownloadManager.m
//  MangaBox
//
//  Created by Ken Tran on 8/4/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "DownloadManager.h"
#import "Chapter+Create.h"
#import "Chapter+UpdateInfo.h"
#import "Page+Create.h"
#import "Page+Getter.h"
#import "MangaFetcher.h"
#import "Manga.h"
#import "MangaBoxAppDelegate.h"

@interface DownloadManager()

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
            [self.queueingChapters removeObjectAtIndex:0];
            if (![self.downloadingChapters containsObject:chapter]
                && ![chapter.downloadStatus isEqualToString:CHAPTER_DOWNLOADED])
            {
#ifdef DEBUG
                NSLog(@"Next chapter: %@", chapter.name);
#endif
                [self startDownloadingChapter:chapter];
            } else {
                [self downloadNextChapter];
            }
        } else {
            // Done
#ifdef DEBUG
            NSLog(@"Nothing more to download");
#endif
        }
    });
}

- (void)prepareNextChapter:(NSNotification *)notification
{
    [self downloadNextChapter];
}

#pragma mark - Download Tasks

- (void)refreshNetworkActivityIndicator
{
    if ([self.downloadingChapters count])
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    else
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)stopAllDownloadingForManga:(Manga *)manga
{
    for (Chapter *chapter in [manga.chapters allObjects]) {
        if ([chapter.downloadStatus isEqualToString:CHAPTER_DOWNLOADING])
            [self stopDownloadingChapter:chapter];
    }
    self.queueingChapters = nil;
}

- (void)stopDownloadingChapter:(Chapter *)chapter
{
    [chapter updateDownloadStatus:CHAPTER_STOPPED_DOWNLOADING];
    [self.downloadingChapters removeObject:chapter];
    [self refreshNetworkActivityIndicator];
}

- (void)finishDownloadingChapter:(Chapter *)chapter
{
    [chapter updateDownloadStatus:CHAPTER_DOWNLOADED];
    [self.downloadingChapters removeObject:chapter];
    
    // Create notification for finishing download chapter
    NSDictionary *userInfo = @{ MANGA_TITLE: chapter.whichManga.title };
    [[NSNotificationCenter defaultCenter] postNotificationName:finishDownloadChapter
                                                        object:self
                                                      userInfo:userInfo];
    
    [((MangaBoxAppDelegate *)[[UIApplication sharedApplication] delegate]) saveDocument];
}

- (void)startDownloadingChapter:(Chapter *)chapter
{
    // Skip if chapter downloaded or downloading
    if (!chapter || [chapter.downloadStatus isEqualToString:CHAPTER_DOWNLOADED] ||
        [chapter.downloadStatus isEqualToString:CHAPTER_DOWNLOADING])
        return;
    
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
    
#ifdef DEBUG
    NSLog(@"START DOWNLOADING CHAPTER: %@", chapter.name);
#endif
    [chapter updateDownloadStatus:CHAPTER_DOWNLOADING];
    [self.downloadingChapters addObject:chapter];
    [self downloadHtmlPage:url forChapter:chapter];
    [self refreshNetworkActivityIndicator];
}


- (void)downloadHtmlPage:(NSURL *)pageHtmlURL forChapter:(Chapter *)chapter
{
    if ([chapter.downloadStatus isEqualToString:CHAPTER_DOWNLOADING]) {
        NSURLRequest *request = [NSURLRequest requestWithURL:pageHtmlURL];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        
#ifdef DEBUG
        NSLog(@"Creating task to download html for chapter: %@", chapter.name);
#endif
        __weak DownloadManager *weakSelf = self;
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
            completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error) {
#ifdef DEBUG
                NSLog(@"Html completionHandler for chapter: %@", chapter.name);
#endif
                if (!error) {
                    // Fetch info according to the source and parse to temporary variable
                    NSDictionary *pageDictionary = [MangaFetcher parseChapterPage:localfile ofChapterURLString:chapter.url];
#ifdef DEBUG
                    NSLog(@"Finish parsing page dictionary for chapter: %@", chapter.name);
                    NSLog(@"%@", pageDictionary);
                    NSLog(@"%lu", (unsigned long)[chapter.pages count]);
#endif
                    
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
                    }
                    
#ifdef DEBUG
                    NSLog(@"Start downloading image file for chapter: %@", chapter.name);
#endif
                    // start download the image if applicable
                    if ([pageDictionary objectForKey:PAGE_IMAGE_URL]) {
                        [weakSelf downloadPageImageWithPageHtmlDictionary:pageDictionary
                                                            ofPageHtmlURL:request.URL
                                                               forChapter:chapter];
                    } else {
                        [weakSelf stopDownloadingChapter:chapter];
                        [weakSelf performSelectorOnMainThread:@selector(alert:)
                                                   withObject:DOWNLOAD_ERROR
                                                waitUntilDone:NO];
                    }
                } else {
#ifdef DEBUG
                    NSLog(@"Download Error");
#endif
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
    
#ifdef DEBUG
    NSLog(@"Creating task to download image for chapter: %@", chapter.name);
#endif
    __weak DownloadManager *weakSelf = self;
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
        completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error) {
#ifdef DEBUG
            NSLog(@"Image completionHandler for chapter: %@", chapter.name);
#endif
            if (!error) {
                @autoreleasepool {
                    
                    NSData *imageData = [NSData dataWithContentsOfURL:localfile];
                    if (!imageData) {
                        // if error, update the download status and return
                        [weakSelf stopDownloadingChapter:chapter];
                        [weakSelf performSelectorOnMainThread:@selector(alert:)
                                                   withObject:DOWNLOAD_ERROR
                                                waitUntilDone:NO];
                        return;
                    }
                    
#ifdef DEBUG
                    NSLog(@"Finish downloading image for chapter: %@", chapter.name);
#endif
                    NSDictionary *pageDictionary = @{PAGE_URL: [pageHtmlURL absoluteString],
                                                     PAGE_IMAGE_URL: [imageURL absoluteString],
                                                     PAGE_IMAGE_DATA: imageData
                                                     };
                    
#ifdef DEBUG
                    NSLog(@"Creating new page object for chapter: %@, with image URL: %@", chapter.name, [imageURL absoluteString]);
#endif
                    
                    // save the page into core data
                    Page *newPage = [Page pageWithInfo:pageDictionary
                                             ofChapter:chapter
                                inManagedObjectContext:chapter.managedObjectContext];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:finishDownloadChapterPage
                                                                    object:self
                                                                  userInfo:@{ CHAPTER_NAME: chapter.name }];

                
                // if all the pages of the chapter is downloaded, reset the downloadStatus
                // and post a notification
                if ([chapter.pagesCount intValue] == [chapter.pages count]) {
                    [weakSelf performSelectorOnMainThread:@selector(finishDownloadingChapter:)
                                               withObject:chapter
                                            waitUntilDone:YES];
                    return;
                }

#ifdef DEBUG
                NSLog(@"Download next html page for chapter: %@, nextpage: %@", chapter.name, [pageHtmlDictionary objectForKey:NEXT_PAGE_TO_PARSE]);
#endif
                
                // Download the next HTML page if applicable
                if ([pageHtmlDictionary objectForKey:NEXT_PAGE_TO_PARSE]) {
                    [weakSelf downloadHtmlPage:[NSURL URLWithString:[pageHtmlDictionary objectForKey:NEXT_PAGE_TO_PARSE]]
                                    forChapter:chapter];
                } else {
                    [weakSelf stopDownloadingChapter:chapter];
                    [weakSelf performSelectorOnMainThread:@selector(alert:)
                                               withObject:DOWNLOAD_ERROR
                                            waitUntilDone:NO];
                }
                
#ifdef DEBUG
                NSLog(@"Exiting completionHandler for image: %@", [imageURL absoluteString]);
#endif
            } else {
                // error
#ifdef DEBUG
                NSLog(@"Download Error");
#endif
                [weakSelf stopDownloadingChapter:chapter];
                [weakSelf performSelectorOnMainThread:@selector(alert:)
                                           withObject:DOWNLOAD_ERROR
                                        waitUntilDone:NO];
            }
            [session invalidateAndCancel];
        }];
    [task resume];
}

- (void)updateChapterListForManga:(Manga *)manga
{
    // Show networkActivityIndicator
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSURL *url = [NSURL URLWithString:manga.url];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    __weak DownloadManager *weakSelf = self;
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
        completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            if (!error) {
                NSArray *chapterList = [MangaFetcher parseChapterList:localfile ofSourceURL:url];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([chapterList count]) {
                        NSArray *chapters = [Chapter loadChaptersFromArray:chapterList
                                               ofManga:manga
                              intoManagedObjectContext:manga.managedObjectContext];
                        [weakSelf notice:[NSString stringWithFormat:@"%lu chapter(s) added", (unsigned long)[chapters count]]];
                    } else {
                        [weakSelf alert:@"Unable to get chapter list"];
                    }
                });
            } else {
#ifdef DEBUG
                NSLog(@"Error retrieving chapterlist");
#endif
                [weakSelf performSelectorOnMainThread:@selector(alert:)
                                       withObject:@"Error retrieving chapterlist"
                                    waitUntilDone:NO];
            }
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
    [Tracker trackDownloadTaskWithAction:@"Alert" label:msg];
}

- (void)notice:(NSString *)msg
{
    [[[UIAlertView alloc] initWithTitle:@"Update"
                                message:msg
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
    [Tracker trackDownloadTaskWithAction:@"Notice" label:msg];
}

@end
