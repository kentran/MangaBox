//
//  SettingsTVC.m
//  MangaBox
//
//  Created by Ken Tran on 16/4/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "SettingsTVC.h"
#import "MangaBoxAppDelegate.h"

@interface SettingsTVC ()
@property (weak, nonatomic) IBOutlet UISwitch *autoSwitchChapter;
@property (weak, nonatomic) IBOutlet UILabel *autoSwitchChapterStatus;

@property (weak, nonatomic) IBOutlet UISwitch *deviceAwakeSwitch;
@property (weak, nonatomic) IBOutlet UILabel *deviceAwakeStatus;

@end

@implementation SettingsTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadUserSettings];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Settings Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    [self loadBackgroundColorForAllCells]; // for disclosure indicator on ipad
}

- (void)loadBackgroundColorForAllCells
{
    for (int section = 0; section < [self.tableView numberOfSections]; section++) {
        for (int row = 0; row < [self.tableView numberOfRowsInSection:section]; row++) {
            NSIndexPath* cellPath = [NSIndexPath indexPathForRow:row inSection:section];
            UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:cellPath];
            cell.backgroundColor = UIColorFromRGB(0x121314);
        }
    }
}

- (void)loadUserSettings
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // Device Awake
    if ([[defaults valueForKey:DEVICE_AWAKE] isEqualToString:DEVICE_AWAKE_ON]) {
        self.deviceAwakeSwitch.on = YES;
        self.deviceAwakeStatus.text = @"On";
    } else {
        self.deviceAwakeSwitch.on = NO;
        self.deviceAwakeStatus.text = @"Off";
    }
    
    // Auto Switch Chapter
    if ([[defaults valueForKey:AUTO_SWITCH_CHAPTER] isEqualToString:AUTO_SWITCH_CHAPTER_ON]) {
        self.autoSwitchChapter.on = YES;
        self.autoSwitchChapterStatus.text = @"On";
    } else {
        self.autoSwitchChapter.on = NO;
        self.autoSwitchChapterStatus.text = @"Off";
    }
}

- (void)saveUserSettings
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // Keep Device Awake
    NSString *deviceAwake = (self.deviceAwakeSwitch.on) ? DEVICE_AWAKE_ON : DEVICE_AWAKE_OFF;
    [defaults setObject:deviceAwake forKey:DEVICE_AWAKE];
    [(MangaBoxAppDelegate *)[[UIApplication sharedApplication] delegate] resetKeepAwakeSetting];
    
    // Auto Switch Chapter
    NSString *autoSwitchChapter = (self.autoSwitchChapter.on) ? AUTO_SWITCH_CHAPTER_ON : AUTO_SWITCH_CHAPTER_OFF;
    [defaults setObject:autoSwitchChapter forKey:AUTO_SWITCH_CHAPTER];
    
    [Tracker trackUserSettingsWithAction:AUTO_SWITCH_CHAPTER label:autoSwitchChapter];
    [Tracker trackUserSettingsWithAction:DEVICE_AWAKE label:deviceAwake];
}

- (IBAction)valueChanged:(UISwitch *)sender
{
    [self saveUserSettings];
    [self loadUserSettings];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.textLabel.text isEqualToString:@"Like MangaBox on Facebook"]) {
        NSURL *fbAppURL = [NSURL URLWithString:FACEBOOK_APP_URL];
        NSURL *fbSafariURL = [NSURL URLWithString:FACEBOOK_SAFARI_URL];
        if ([[UIApplication sharedApplication] canOpenURL:fbAppURL]) {
            [[UIApplication sharedApplication] openURL:fbAppURL];
        } else if ([[UIApplication sharedApplication] canOpenURL:fbSafariURL]) {
            [[UIApplication sharedApplication] openURL:fbSafariURL];
        }
    } else if ([cell.textLabel.text isEqualToString:@"Report a Problem"]) {
        NSString *mail = @"mangaboxdev@gmail.com";
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"mailto:?to=%@", [mail stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]];
        [[UIApplication sharedApplication] openURL:url];
    }
}

@end
