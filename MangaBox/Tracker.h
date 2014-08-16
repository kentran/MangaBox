//
//  Tracker.h
//  MangaBox
//
//  Created by Ken Tran on 17/8/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tracker : NSObject

+ (void)trackAdvancedSearchWithAction:(NSString *)action label:(NSString *)label;
+ (void)trackDownloadTaskWithAction:(NSString *)action label:(NSString *)label;
+ (void)trackPopularWithAction:(NSString *)action label:(NSString *)label;
+ (void)trackUserSettingsWithAction:(NSString *)action label:(NSString *)label;

@end
