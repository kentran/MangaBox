//
//  MangaDetailsViewController.h
//  MangaBox
//
//  Created by Ken Tran on 2/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MangaDetailsViewController : UIViewController
@property (strong, nonatomic) NSURL *mangaURL;
@property (strong, nonatomic) NSDictionary *mangaDetails;
@property (strong, nonatomic) NSString *mangaUnique;
@property (strong, nonatomic) NSString *chaptersCount;
@end
