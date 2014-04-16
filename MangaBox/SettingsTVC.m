//
//  SettingsTVC.m
//  MangaBox
//
//  Created by Ken Tran on 16/4/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "SettingsTVC.h"
#import "MangaBoxSettingsPropertyKeys.h"
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
}

- (IBAction)valueChanged:(UISwitch *)sender
{
    [self saveUserSettings];
    [self loadUserSettings];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
