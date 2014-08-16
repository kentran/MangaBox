//
//  Tracker.m
//  MangaBox
//
//  Created by Ken Tran on 17/8/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "Tracker.h"

@implementation Tracker

+ (void)trackAdvancedSearchWithAction:(NSString *)action label:(NSString *)label
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Advanced Search"
                                                          action:action
                                                           label:label
                                                           value:nil] build]];
}

+ (void)trackDownloadTaskWithAction:(NSString *)action label:(NSString *)label
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Download Task"
                                                          action:action
                                                           label:label
                                                           value:nil] build]];
}

+ (void)trackPopularWithAction:(NSString *)action label:(NSString *)label
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Popular Events"
                                                          action:action
                                                           label:label
                                                           value:nil] build]];
}

+ (void)trackUserSettingsWithAction:(NSString *)action label:(NSString *)label
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"User Settings"
                                                          action:action
                                                           label:label
                                                           value:nil] build]];
}

@end
