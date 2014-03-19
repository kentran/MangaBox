//
//  Chapter+Download.m
//  MangaBox
//
//  Created by Ken Tran on 18/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "Chapter+Download.h"
#import "MangafoxFetcher.h"
#import "MangaDictionaryDefinition.h"
#import "Page+Create.h"

@implementation Chapter (Download)

+ (void)startDownloadingChapterPages:(Chapter *)chapter
{
    NSURL *url = [NSURL URLWithString:chapter.url];
    [self startDownloadingPages:url ofChapter:chapter];
}

+ (void)startDownloadingPages:(NSURL *)pageHtmlURL ofChapter:(Chapter *)chapter
{
    NSURLRequest *request = [NSURLRequest requestWithURL:pageHtmlURL];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
        completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error) {
            if (!error) {
                if ([request.URL isEqual:pageHtmlURL]) {
                    NSString *urlString = [request.URL absoluteString];
                    NSData *htmlData = [NSData dataWithContentsOfURL:localfile];
                    
                    NSDictionary *pageDictionary;
                    if ([urlString rangeOfString:@"mangafox.me"].location != NSNotFound) {
                        pageDictionary = [MangafoxFetcher parseChapterPage:htmlData ofURLString:chapter.url];
                    }
                    
                    // Set the pagesCount in chapter if it is not already set
                    if (!chapter.pagesCount && [pageDictionary objectForKey:PAGES_COUNT]) {
                        chapter.pagesCount = [pageDictionary objectForKey:PAGES_COUNT];
                        [chapter.managedObjectContext save:NULL];
                    }
                    
                    if ([pageDictionary objectForKey:PAGE_IMAGE_URL])
                        [self startDownloadingPageImage:[NSURL URLWithString:[pageDictionary objectForKey:PAGE_IMAGE_URL]]
                                          ofPageHtmlURL:pageHtmlURL
                                              ofChapter:chapter];
                    if ([pageDictionary objectForKey:NEXT_PAGE_TO_PARSE])
                        [self startDownloadingPages:[NSURL URLWithString:[pageDictionary objectForKey:NEXT_PAGE_TO_PARSE]] ofChapter:chapter];
                }
            }
        }];
    [task resume];
}

+ (void)startDownloadingPageImage:(NSURL *)imageURL
                    ofPageHtmlURL:(NSURL *)pageHtmlURL
                        ofChapter:(Chapter *)chapter
{
    NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
        completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error) {
            if (!error) {
                if ([request.URL isEqual:imageURL]) {
                    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:localfile]];
                    NSDictionary *pageDictionary = @{PAGE_URL: [pageHtmlURL absoluteString],
                                                      PAGE_IMAGE_URL: [imageURL absoluteString],
                                                      PAGE_IMAGE_DATA: UIImageJPEGRepresentation(image, 1.0)
                                                      };

                    [Page pageWithInfo:pageDictionary
                             ofChapter:chapter
                inManagedObjectContext:chapter.managedObjectContext];
                    
                    [chapter.managedObjectContext save:NULL];
                }
            }
        }];
    [task resume];
}

@end
