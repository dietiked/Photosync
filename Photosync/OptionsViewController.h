//
//  OptionsViewController.h
//  Photosync
//
//  Created by dominique on 31.12.15.
//  Copyright © 2015 dominique. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface OptionsViewController : NSViewController {
    IBOutlet NSButton *jpgCheckbox;
    IBOutlet NSButton *pngCheckbox;
    IBOutlet NSButton *tifCheckbox;
    IBOutlet NSButton *nefCheckbox;
    IBOutlet NSButton *dngCheckbox;
    IBOutlet NSButton *xmpCheckbox;
    IBOutlet NSButton *gifCheckbox;
    IBOutlet NSButton *cr2Checkbox;
    IBOutlet NSButton *onlyMissingFiles;
}

- (IBAction)updateUserDefaults:(id)sender;

@end
