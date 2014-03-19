//
//  MangaCDTVC.h
//  MangaBox
//
//  Created by Ken Tran on 9/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface MangasCDTVC : CoreDataTableViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSDictionary *addedMangaDictionary;

@end
