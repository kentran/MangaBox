//
//  SearchedMangaViewController.h
//  MangaBox
//
//  Created by Ken Tran on 2/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "MangaListTVC.h"

@interface SearchedMangaViewController : MangaListTVC
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *artist;

@property (nonatomic, strong) NSDictionary *genres;

@property (nonatomic, strong) NSString *released;
@property (nonatomic, strong) NSString *rating;
@property (nonatomic, strong) NSString *isCompleted;

- (NSArray *) fetchMangas;
@end
