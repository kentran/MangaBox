//
//  ChaptersCDTVC.h
//  MangaBox
//
//  Created by Ken Tran on 11/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface ChaptersCDTVC : CoreDataTableViewController

// generic Chapter displaying CDTVC
// hook up fetchedResultsController to any Chapter fetch request
// use @"Chapter Cell" as your table view cell's reuse id
// will segue to viewing chapter content

@end
