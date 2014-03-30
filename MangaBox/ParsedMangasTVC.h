//
//  MangaListTVC.h
//  MangaBox
//
//  Created by Ken Tran on 2/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParsedMangasTVC : UITableViewController

@property (strong, nonatomic) NSArray *mangas;

- (void)alert:(NSString *)msg;
- (void)fatalAlert:(NSString *)msg;

@end
