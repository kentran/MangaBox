//
//  MangaBoxMasterViewController.h
//  MangaBox
//
//  Created by Ken Tran on 1/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MangaBoxDetailViewController;

#import <CoreData/CoreData.h>

@interface MangaBoxMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) MangaBoxDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) NSArray *mangas;

@end
