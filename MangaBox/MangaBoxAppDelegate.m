//
//  MangaBoxAppDelegate.m
//  MangaBox
//
//  Created by Ken Tran on 1/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "MangaBoxAppDelegate.h"
#import "MenuTabBarController.h"
#import "Chapter+UpdateInfo.h"
#import "MangaBoxSettingsPropertyKeys.h"

@implementation MangaBoxAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    /* Set up Google Analytics */
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    //[GAI sharedInstance].dispatchInterval = 20;
    // Optional: set Logger to VERBOSE for debug information.
    //[[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    
    // Create tracker instance.
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:TRACKING_ID];
    
    /* Create UIManaged Document */
    NSURL *url = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MangaBox"];
    self.document = [[UIManagedDocument alloc] initWithFileURL:url];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    self.document.persistentStoreOptions = options;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        [self.document openWithCompletionHandler:^(BOOL success) {
            if (success) [self documentIsReady];
            if (!success) NSLog(@"couldn’t open document at %@", url);
        }];
    } else {
        [self.document saveToURL:url forSaveOperation:UIDocumentSaveForCreating
           completionHandler:^(BOOL success) {
               if (success) [self documentIsReady];
               if (!success) NSLog(@"couldn’t create document at %@", url);
           }];
    }
    
    [self loadDefaultSettings];
    [self resetKeepAwakeSetting];
    
    /* Cutomize appearance */
    
    // Global tint color
    [self.window setTintColor:UIColorFromRGB(0x648f00)];
    
    // Status bar
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // UINavigationBar
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackTranslucent];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[GAI sharedInstance] dispatch];
    [self saveDocument];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self saveDocument];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
}

// If app settings are not set, set the default values
- (void)loadDefaultSettings
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults valueForKey:DEVICE_AWAKE]) {
        [defaults setObject:DEVICE_AWAKE_ON forKey:DEVICE_AWAKE];
    }
    
    if (![defaults valueForKey:AUTO_SWITCH_CHAPTER]) {
        [defaults setObject:AUTO_SWITCH_CHAPTER_ON forKey:AUTO_SWITCH_CHAPTER];
    }
}

// Reset the Keep awake status for the app based on the current settings
- (void)resetKeepAwakeSetting
{
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:DEVICE_AWAKE] isEqualToString:DEVICE_AWAKE_ON])
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    else
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)documentIsReady
{
    if (self.document.documentState == UIDocumentStateNormal) {
        NSManagedObjectContext *context = self.document.managedObjectContext;
        if ([self.window.rootViewController isKindOfClass:[MenuTabBarController class]]) {
            MenuTabBarController *tabBarController = (MenuTabBarController *)self.window.rootViewController;
            tabBarController.managedObjectContext = context;
        }
        [Chapter refreshDownloadStatusInContext:context];
    }
}

- (void)saveDocument
{
    [self.document saveToURL:self.document.fileURL
            forSaveOperation:UIDocumentSaveForOverwriting
           completionHandler:^(BOOL success) {
               if (!success) {
                   NSLog(@"Save Error");
               }
    }];
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
