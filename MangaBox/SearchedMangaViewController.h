//
//  SearchedMangaViewController.h
//  MangaBox
//
//  Created by Ken Tran on 2/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "MangaListTVC.h"

@interface SearchedMangaViewController : MangaListTVC

@property (nonatomic, strong) NSDictionary *criteria;

- (NSArray *) fetchMangas;
@end
