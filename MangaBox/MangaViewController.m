//
//  MangaViewController.m
//  MangaBox
//
//  Created by Ken Tran on 6/7/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "MangaViewController.h"
#import "ChaptersByMangaCDTVC.h"
#import "CoverImage.h"

@interface MangaViewController ()

@property (nonatomic, strong) ChaptersByMangaCDTVC *chaptersByMangaVC;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusTextLabel;

@end

@implementation MangaViewController

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.coverImageView.image = [UIImage imageWithData:self.manga.cover.imageData];
    self.titleTextLabel.text = self.manga.title;
    self.authorTextLabel.text = self.manga.author;
    self.artistTextLabel.text = self.manga.artist;
    self.statusTextLabel.text = self.manga.completionStatus;
    
    /* Background Image */
    UIImage *blurImage = [[UIImage imageWithData:self.manga.cover.imageData] imageByApplyingFilterNamed:@"CIGaussianBlur"];
    
    //self.view.backgroundColor = [[UIColor colorWithPatternImage:backgroundImage] colorWithAlphaComponent:0.19f];
    self.backgroundImage.image = blurImage;
}

#pragma mark - Properties

- (void)setManga:(Manga *)manga
{
    _manga = manga;
    self.chaptersByMangaVC.manga = _manga;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[ChaptersByMangaCDTVC class]]) {
        ChaptersByMangaCDTVC *cbmcdtvc = (ChaptersByMangaCDTVC *)segue.destinationViewController;
        cbmcdtvc.manga = self.manga;
        self.chaptersByMangaVC = cbmcdtvc;
    }
}


@end
