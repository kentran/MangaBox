//
//  Chapter+Download.m
//  MangaBox
//
//  Created by Ken Tran on 18/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "Chapter+Download.h"
#import "MangafoxFetcher.h"
#import "MangareaderFetcher.h"
#import "MangaDictionaryDefinition.h"
#import "MangaBoxNotification.h"
#import "Page+Create.h"
#import "Page+Getter.h"
#import "Manga.h"
#import "MangaBoxAppDelegate.h"

@implementation Chapter (Download)

#pragma mark - Download task

- (void)startDownloadingChapterPages
{
    // If the chapter has been downloading half way
    // continue from the last downloaded page
    NSURL *url;
    if ([self.pages count]) {
        NSInteger lastPageIdx = [self.pages count] - 1;
        Page *lastDownloadedPage = [Page pageOfChapter:self atIndex:lastPageIdx];
        url = [NSURL URLWithString:lastDownloadedPage.url];
    } else {
        url = [NSURL URLWithString:self.url];
    }
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    //[self startDownloadingPages:url ofChapter:chapter withSession:session];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
        completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
            if (!error) {
                [self downloadHtmlPages:url];
            }
        }];
    [task resume];
}

- (void)downloadHtmlPages:(NSURL *)pageHtmlURL
{
    if ([self.downloadStatus isEqualToString:CHAPTER_DOWNLOADING]) {
        NSString *urlString = [pageHtmlURL absoluteString];
        NSData *htmlData = [NSData dataWithContentsOfURL:pageHtmlURL];
        
        // Fetch info according to the source and parse to temporary variable
        NSDictionary *pageDictionary;
        if ([urlString rangeOfString:@"mangafox.me"].location != NSNotFound) {
            pageDictionary = [MangafoxFetcher parseChapterPage:htmlData ofURLString:self.url];
        } else if ([urlString rangeOfString:@"mangareader.net"].location != NSNotFound) {
            pageDictionary = [MangareaderFetcher parseChapterPage:htmlData ofURLString:self.url];
        }
        
        // Check if the page is downloaded correctly
        if ([self.pagesCount intValue] != [self.pages count]
            && ![pageDictionary objectForKey:PAGE_IMAGE_URL])
        {
            [self errorHandling];
            return;
        }
        
        
        // Set the pagesCount in chapter if it is not already set
        if (![self.pagesCount intValue] && [pageDictionary objectForKey:PAGES_COUNT]) {
            self.pagesCount = [NSNumber numberWithInt:[[pageDictionary objectForKey:PAGES_COUNT] intValue]];
            [(MangaBoxAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
        }
        
        // start download the image if applicable
        if ([pageDictionary objectForKey:PAGE_IMAGE_URL]) {
            [self downloadPageImage:[NSURL URLWithString:[pageDictionary objectForKey:PAGE_IMAGE_URL]]
                              ofPageHtmlURL:pageHtmlURL];
        }
        
        NSLog(@"%@", pageDictionary);
        NSLog(@"%@", self);
        // fetch the next html page to parse if applicable
        if ([pageDictionary objectForKey:NEXT_PAGE_TO_PARSE])
            [self downloadHtmlPages:[NSURL URLWithString:[pageDictionary objectForKey:NEXT_PAGE_TO_PARSE]]];
    }
}

- (void)downloadPageImage:(NSURL *)imageURL
                    ofPageHtmlURL:(NSURL *)pageHtmlURL
{
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    if (!imageData) { // if error, update the download status and return
        [self errorHandling];
        return;
    }
    
    UIImage *image = [UIImage imageWithData:imageData];
    NSDictionary *pageDictionary = @{PAGE_URL: [pageHtmlURL absoluteString],
                                     PAGE_IMAGE_URL: [imageURL absoluteString],
                                     PAGE_IMAGE_DATA: UIImageJPEGRepresentation(image, 1.0)
                                     };
    
    // save the page into core data
    Page *newPage = [Page pageWithInfo:pageDictionary
                             ofChapter:self
                inManagedObjectContext:self.managedObjectContext];
    
    // update the chapter updated attribute
    newPage.whichChapter.updated = [NSDate date];
    
    // if all the pages of the chapter is downloaded, reset the downloadStatus
    // and post a notification
    if ([self.pagesCount intValue] == [self.pages count]) {
        NSLog(@"Done");
        self.downloadStatus = CHAPTER_DOWNLOADED;
        [[NSNotificationCenter defaultCenter] postNotificationName:finishDownloadChapter object:self];
    }
    
    [(MangaBoxAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
}

- (void)stopDownloadingChapterPages
{
    if ([self.downloadStatus isEqualToString:CHAPTER_DOWNLOADING]) {
        self.downloadStatus = CHAPTER_STOPPED_DOWNLOADING;
        [(MangaBoxAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
    }
}

#pragma mark - Error report

- (void)errorHandling
{
    NSDictionary *error = @{ @"msg": @"Error downloading pages. Pages may not be available at the moment. Please try again later" };
    [[NSNotificationCenter defaultCenter] postNotificationName:errorDownloadingChapter
                                                        object:self
                                                      userInfo:error];
    
    self.downloadStatus = CHAPTER_STOPPED_DOWNLOADING;
    [(MangaBoxAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
}

@end
