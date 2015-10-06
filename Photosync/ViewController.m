//
//  ViewController.m
//  Photosync
//
//  Created by dominique on 26.12.14.
//  Copyright (c) 2014 dominique. All rights reserved.
//

#import "ViewController.h"
#import "MissingFile.h"

NSString* const LOCALFOLDER = @"localFolderFullPath";
NSString* const REMOTEFOLDER = @"remoteFolderFullPath";

@implementation ViewController
@synthesize missingFiles;
@synthesize remoteFolderFullPath, localFolderFullPath;
@synthesize isButtonEnabled;

- (void)viewDidLoad {
    [super viewDidLoad];
    openPanel = [NSOpenPanel openPanel];
    openPanel.title = @"Select local photo folder";
    openPanel.canChooseFiles = NO;
    openPanel.canChooseDirectories = YES;
    openPanel.canCreateDirectories = YES;
    openPanel.allowsMultipleSelection = NO;
    openPanel.directoryURL = [NSURL URLWithString:@"~/pictures"];

    // Do any additional setup after loading the view.
    
    missingFiles = [NSMutableArray array];
    [self setLocalFolderFullPath:[[NSUserDefaults standardUserDefaults] objectForKey:LOCALFOLDER]];
    [self setRemoteFolderFullPath:[[NSUserDefaults standardUserDefaults] objectForKey:REMOTEFOLDER]];
    [self setUserMessage:@""];
    [self setIsButtonEnabled:YES];
    [scanProgressIndicator setUsesThreadedAnimation:YES];
    [copyProgressIndicator setUsesThreadedAnimation:YES];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (BOOL)isPictureOrFolder:(NSString*)filepath {
    //NSArray* components = [filename componentsSeparatedByString:@"."];
    //NSString* extension = [components objectAtIndex:[components count]-1];
    NSString *extension = [filepath pathExtension];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //NSLog(@"Extension: %@", extension);
    BOOL isDir;
    if ([fileManager fileExistsAtPath:filepath isDirectory:&isDir] && isDir) {
        return true;
    }
    
    if ([extension isEqualToString:@"png"] || [extension isEqualToString:@"PNG"]) {
    } else if ([extension isEqualToString:@"jpg"] || [extension isEqualToString:@"JPG"]) {
        return true;

    } else if ([extension isEqualToString:@"jpeg"] || [extension isEqualToString:@"JPEG"]) {
        return true;
        
    } else if ([extension isEqualToString:@"gif"] || [extension isEqualToString:@"GIF"]) {
        return true;
        
    } else if ([extension isEqualToString:@"raw"] || [extension isEqualToString:@"RAW"]) {
        return true;
        
    } else if ([extension isEqualToString:@"nef"] || [extension isEqualToString:@"NEF"]) {
        return true;
        
    } else if ([extension isEqualToString:@"dng"] || [extension isEqualToString:@"DNG"]) {
        return true;
        
    } else if ([extension isEqualToString:@"cr2"] || [extension isEqualToString:@"CR2"]) {
        return true;
        
    } else if ([extension isEqualToString:@"tif"] || [extension isEqualToString:@"TIF"]) {
        return true;
    
    } else if ([extension isEqualToString:@"tiff"] || [extension isEqualToString:@"TIFF"]) {
        return true;
        
    } else if ([extension isEqualToString:@"xmp"] || [extension isEqualToString:@"XMP"]) {
        return true;
        
    }

    return false;

}

- (IBAction)openLocalFolderPath:(id)sender {
    NSLog(@"Open local folder path");
    [openPanel runModal];
    NSLog(@"%@", openPanel.URL);
    [self setLocalFolderFullPath:[openPanel.URL relativePath]];
    [[NSUserDefaults standardUserDefaults] setObject:localFolderFullPath forKey:LOCALFOLDER];
    
}

- (IBAction)openRemoteFolderPath:(id)sender {
    NSLog(@"Open local folder path");
    [openPanel runModal];
    NSLog(@"%@", openPanel.URL);
    [self setRemoteFolderFullPath:[openPanel.URL relativePath]];
    [[NSUserDefaults standardUserDefaults] setObject:remoteFolderFullPath forKey:REMOTEFOLDER];
   
}

#pragma mark Scan methods
- (IBAction)scan:(id)sender {
    // Perfom scan on a new thread
    [NSThread detachNewThreadSelector:@selector(performScan) toTarget:self withObject:nil];
}

- (NSMutableArray*)contentForFolderAtPath:(NSString*)fullFolderPath {
    // Mutable array for missing elements
    NSMutableArray *elements = [NSMutableArray array];
    // Default file manager
    NSFileManager* fileManager = [NSFileManager defaultManager];
    // Get the folder content
    NSArray* folderContent = [fileManager contentsOfDirectoryAtPath:fullFolderPath error:nil];
    // Loop over all files and folders
    for (NSInteger i=0; i<[folderContent count]; i++) {
        // The file/folder --> Not the full path!
        NSString *fileName = [folderContent objectAtIndex:i];
        // This is the file/folder full path
        NSString *fileFullPath = [fullFolderPath stringByAppendingPathComponent:fileName];
        // Now split the full path in two: first the local root, then the relative file path
        NSArray *filePathComponents = [fileFullPath componentsSeparatedByString:self.localFolderFullPath];
        NSString *relativeFilePath = [filePathComponents objectAtIndex:[filePathComponents count]-1];
        // The remote file should be here (if it exists): remote root + relative file path
        NSString *remoteFilePath = [self.remoteFolderFullPath stringByAppendingPathComponent:relativeFilePath];
        // Check if local file exists on remote folder
        BOOL isDir;
        BOOL isPictureOrFolder = [self isPictureOrFolder:fileFullPath];
        if ([fileManager fileExistsAtPath:fileFullPath isDirectory:&isDir] && !isDir && isPictureOrFolder) {
            if (! [fileManager fileExistsAtPath:remoteFilePath]) {
                MissingFile* missingFile = [[MissingFile alloc] initWithLocalFilePath:fileFullPath andRemoteFilePath:remoteFilePath];
                
                [elements addObject:missingFile];                
            }
        } else if ([fileManager fileExistsAtPath:fileFullPath isDirectory:&isDir] && isDir) {
            MissingFile* missingFile = [[MissingFile alloc] initWithLocalFilePath:fileFullPath andRemoteFilePath:remoteFilePath];
            
            [missingFile setChildren:[self contentForFolderAtPath:fileFullPath]];
            [missingFile setIsFile:NO];
            [elements addObject:missingFile];
        }
    }
    return elements;
}

- (void)performScan {
    // If a path is missing, inform the user and stop execution
    if (!remoteFolderFullPath || !localFolderFullPath) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert setMessageText:@"Please select local and remote folders!"];
        [alert beginSheetModalForWindow:self.view.window completionHandler:nil];
        return;
    }
    // Check if filepath are available (may not be for server resources)
    NSFileManager *filemanager = [NSFileManager defaultManager];
    if (! [filemanager fileExistsAtPath:remoteFolderFullPath] ) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert setMessageText:[NSString stringWithFormat:@"%@ is not available.", remoteFolderFullPath]];
        [alert beginSheetModalForWindow:self.view.window completionHandler:nil];
        return;
    } else if (! [filemanager fileExistsAtPath:localFolderFullPath] ) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert setMessageText:[NSString stringWithFormat:@"%@ is not available.", localFolderFullPath]];
        [alert beginSheetModalForWindow:self.view.window completionHandler:nil];
        return;
    }
    // Everything is ok, proceed to scan folder
    // Disable buttons
    [self setIsButtonEnabled:NO];
    // Start progress indicator
    [scanProgressIndicator setHidden:false];
    [scanProgressIndicator startAnimation:self];
    // Perform scan
    NSMutableArray *missings = [self contentForFolderAtPath:localFolderFullPath];
    for (NSInteger i=0; i<[missings count]; i++) {
        MissingFile *file = [missings objectAtIndex:i];
        [file calculateNumberOfMissingFiles];
    }
    // Send the scan result to the main thread
    [self performSelectorOnMainThread:@selector(scanDidComplete:) withObject:missings waitUntilDone:YES];
    // Stop progress indicator
    [scanProgressIndicator stopAnimation:self];
    [scanProgressIndicator setHidden:true];
    // Enable buttons
    [self setIsButtonEnabled:YES];

}

// This method is called once the scan has been completed
- (void)scanDidComplete:(NSMutableArray*)scanResult {
    [self setMissingFiles:scanResult];
}


#pragma mark Copy methods
- (IBAction)copySelected:(id)sender {
    // Start progress indicator
    [copyProgressIndicator setHidden:false];
    [copyProgressIndicator startAnimation:self];
    // Find which file has been selected
    NSIndexPath *indexPath = [browser selectionIndexPath];
    MissingFile *next = [missingFiles objectAtIndex:[indexPath indexAtPosition:0]];
    for (NSInteger i=1; i<[indexPath length]; i++) {
        next = [[next children] objectAtIndex:[indexPath indexAtPosition:i]];
    }
    // Copy the file on a new thread --> Necessary for large files/folders
    [NSThread detachNewThreadSelector:@selector(copyFile:) toTarget:self withObject:next];
    
}

- (void)copyFile:(MissingFile*)file {
    // Set progress indicator
    [copyProgressIndicator setMinValue:0.0];
    [copyProgressIndicator setMaxValue:100.0];
    [copyProgressIndicator setDoubleValue:0.0];
    // Disable all buttons
    [self setIsButtonEnabled:NO];
    // Start a timer to update the progress indicator. The timer runs on a separated thread
    NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(checkCurrentFileSize:) userInfo:file repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    // Copy the file
    [file copyFile];
    // Once finished stop the progress indicator and activate all buttons
    [copyProgressIndicator setDoubleValue:100.0];
    [copyProgressIndicator setHidden:true];
    [copyProgressIndicator stopAnimation:self];
    // Stop the timer
    [timer invalidate];
    // Inform the user
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert setMessageText:[NSString stringWithFormat:@"%@ has been copied to %@.", file.filename, file.remoteFilePath]];
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
        [self setIsButtonEnabled:YES];
    }];
}

// Update progress indicator
- (void)checkCurrentFileSize:(NSTimer*)timer {
    // Get the file/folder that is duplicating
    MissingFile *file = [timer userInfo];
    // Calculate file sizes
    NSDictionary *fileSize = [file fileSize];
    unsigned long long totalSize = [[fileSize objectForKey:@"sizeLocal"] unsignedLongLongValue];
    unsigned long long currentSize = [[fileSize objectForKey:@"sizeRemote"] unsignedLongLongValue];
    // Calculate progress
    double percentage = (double) currentSize / totalSize * 100.0;
    // Update progress indicator
    [copyProgressIndicator setDoubleValue:percentage];
    
}


- (IBAction)selectAll:(id)sender {
    for (NSInteger i=0; i<[self.missingFiles count]; i++) {
        MissingFile *file = (MissingFile*)[missingFiles objectAtIndex:i];
        [file setIsSelected:true];
    }
}

- (IBAction)deselectAll:(id)sender {
    for (NSInteger i=0; i<[self.missingFiles count]; i++) {
        MissingFile *file = (MissingFile*)[missingFiles objectAtIndex:i];
        [file setIsSelected:false];
    }
    
}

- (IBAction)revertFolders:(id)sender {
    NSString *tempLocalPath = [NSString stringWithString:self.localFolderFullPath];
    [self setLocalFolderFullPath:[self remoteFolderFullPath]];
    [self setRemoteFolderFullPath:tempLocalPath];
}

- (IBAction)viewInFinder:(NSButtonCell*)sender {
    NSIndexPath *indexPath = [browser selectionIndexPath];
    MissingFile *next = [missingFiles objectAtIndex:[indexPath indexAtPosition:0]];
    for (NSInteger i=1; i<[indexPath length]; i++) {
        next = [[next children] objectAtIndex:[indexPath indexAtPosition:i]];
    }
    NSURL *fileURL = [NSURL fileURLWithPath:next.filepath];
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:[NSArray arrayWithObject:fileURL]];
}


@end
