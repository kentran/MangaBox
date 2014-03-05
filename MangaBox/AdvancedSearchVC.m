//
//  AdvancedSearchVC.m
//  MangaBox
//
//  Created by Ken Tran on 6/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "AdvancedSearchVC.h"
#import "SearchedMangaViewController.h"

@interface AdvancedSearchVC ()
@property (weak, nonatomic) IBOutlet UITextField *seriesNameField;
@property (weak, nonatomic) IBOutlet UITextField *authorNameField;
@property (weak, nonatomic) IBOutlet UITextField *artistNameField;

@end

@implementation AdvancedSearchVC

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[SearchedMangaViewController class]]) {
        SearchedMangaViewController *smvc = segue.destinationViewController;
        smvc.name = self.seriesNameField.text;
        smvc.author = self.authorNameField.text;
        smvc.artist = self.artistNameField.text;
    }
}

@end
