//
//  ViewController.h
//  Photosync
//
//  Created by dominique on 26.12.14.
//  Copyright (c) 2014 dominique. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController {
    
    NSString* remoteFolderFullPath;
    NSString* localFolderFullPath;
    NSString* userMessage;
    NSOpenPanel* openPanel;
    NSMutableArray* missingFiles;
    IBOutlet NSBrowser* browser;
    IBOutlet NSProgressIndicator *progressIndicator;
}

- (IBAction)openRemoteFolderPath:(id)sender;
- (IBAction)openLocalFolderPath:(id)sender;
- (IBAction)scan:(id)sender;
- (IBAction)copySelected:(id)sender;
- (IBAction)selectAll:(id)sender;
- (IBAction)deselectAll:(id)sender;
- (IBAction)revertFolders:(id)sender;
- (IBAction)viewInFinder:(id)sender;

@property NSString *remoteFolderFullPath;
@property NSString *localFolderFullPath;
@property NSString *userMessage;
@property NSMutableArray* missingFiles;

@end

