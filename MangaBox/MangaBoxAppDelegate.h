//
//  MangaBoxAppDelegate.h
//  MangaBox
//
//  Created by Ken Tran on 1/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Chapter.h"

@interface MangaBoxAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) UIManagedDocument *document;

- (NSURL *)applicationDocumentsDirectory;
- (void)resetKeepAwakeSetting;
- (void)saveDocument;

@end
