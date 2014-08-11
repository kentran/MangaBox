//
//  AddMangaConfirmViewController.h
//  MangaBox
//
//  Created by Ken Tran on 22/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddMangaConfirmViewController : UITableViewController

/* This view controller is a place to make sure the info is loaded before
 * the manga is added to collection, there are labels to display but for
 * better user experience, the manga is automatically added when its information
 * is fully loaded
 */

@property (nonatomic, strong) NSURL *mangaURL;

@end
