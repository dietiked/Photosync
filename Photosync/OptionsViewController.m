//
//  OptionsViewController.m
//  Photosync
//
//  Created by dominique on 31.12.15.
//  Copyright © 2015 dominique. All rights reserved.
//

#import "OptionsViewController.h"
#import "UserDefaults.h"

@interface OptionsViewController ()

@end

@implementation OptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isJpg = [userDefaults boolForKey:FILETYPE_JPG];
    BOOL isPng = [userDefaults boolForKey:FILETYPE_PNG];
    BOOL isGif = [userDefaults boolForKey:FILETYPE_GIF];
    BOOL isTif = [userDefaults boolForKey:FILETYPE_TIF];
    BOOL isNef = [userDefaults boolForKey:FILETYPE_NEF];
    BOOL isDng = [userDefaults boolForKey:FILETYPE_DNG];
    BOOL isXmp = [userDefaults boolForKey:FILETYPE_XMP];
    BOOL isCr2 = [userDefaults boolForKey:FILETYPE_CR2];
    BOOL isOnlyMissingFiles = [userDefaults boolForKey:ONLY_MISSING_FILES];

    [jpgCheckbox setState:isJpg];
    [pngCheckbox setState:isPng];
    [tifCheckbox setState:isTif];
    [gifCheckbox setState:isGif];
    [nefCheckbox setState:isNef];
    [dngCheckbox setState:isDng];
    [cr2Checkbox setState:isCr2];
    [xmpCheckbox setState:isXmp];
    [onlyMissingFiles setState:isOnlyMissingFiles];
}

- (IBAction)updateUserDefaults:(id)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:[jpgCheckbox state] forKey:FILETYPE_JPG];
    [userDefaults setBool:[pngCheckbox state] forKey:FILETYPE_PNG];
    [userDefaults setBool:[tifCheckbox state] forKey:FILETYPE_TIF];
    [userDefaults setBool:[gifCheckbox state] forKey:FILETYPE_GIF];
    [userDefaults setBool:[nefCheckbox state] forKey:FILETYPE_NEF];
    [userDefaults setBool:[dngCheckbox state] forKey:FILETYPE_DNG];
    [userDefaults setBool:[cr2Checkbox state] forKey:FILETYPE_CR2];
    [userDefaults setBool:[xmpCheckbox state] forKey:FILETYPE_XMP];
    [userDefaults setBool:[onlyMissingFiles state] forKey:ONLY_MISSING_FILES];
    
    [self dismissController:nil];
}

@end
