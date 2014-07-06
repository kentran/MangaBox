//
//  HomeViewController.m
//  MangaBox
//
//  Created by Ken Tran on 5/7/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "HomeViewController.h"
#import "MangasCDTVC.h"
#import "ChaptersByBookmarkCDTVC.h"
#import "MenuTabBarController.h"
#import "MangaBoxAppDelegate.h"

@interface HomeViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *viewsSegmentControl;

@property (weak, nonatomic) IBOutlet UIView *mangasContainer;
@property (weak, nonatomic) IBOutlet UIView *bookmarksContainer;
@end

@implementation HomeViewController

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.viewsSegmentControl addTarget:self action:@selector(switchView) forControlEvents:UIControlEventValueChanged];
}

- (void)switchView
{
    // Display the correct View Controller when segment is selected
    switch (self.viewsSegmentControl.selectedSegmentIndex) {
        case 0:
            self.mangasContainer.hidden = NO;
            self.bookmarksContainer.hidden = YES;
            break;
        
        case 1:
            self.mangasContainer.hidden = YES;
            self.bookmarksContainer.hidden = NO;
            break;
            
        default: break;
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSManagedObjectContext *context = ([(MangaBoxAppDelegate *)[[UIApplication sharedApplication] delegate] document]).managedObjectContext;

    if ([segue.destinationViewController isKindOfClass:[MangasCDTVC class]]) {
        MangasCDTVC *mcdtvc = (MangasCDTVC *)segue.destinationViewController;
        mcdtvc.managedObjectContext = context;
    } else if ([segue.destinationViewController isKindOfClass:[ChaptersByBookmarkCDTVC class]]) {
        ChaptersByBookmarkCDTVC *cbbcdtvc = (ChaptersByBookmarkCDTVC *)segue.destinationViewController;
        cbbcdtvc.managedObjectContext = context;
    }
}


@end
