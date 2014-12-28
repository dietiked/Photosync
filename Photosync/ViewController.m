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
@synthesize remoteFolderFullPath, localFolderFullPath, userMessage;

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
    [progressIndicator setUsesThreadedAnimation:YES];
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
    
    if ([extension isEqualToString:@"png"]) {
    } else if ([extension isEqualToString:@"jpg"]) {
        return true;

    } else if ([extension isEqualToString:@"jpeg"]) {
        return true;
        
    } else if ([extension isEqualToString:@"gif"]) {
        return true;
        
    } else if ([extension isEqualToString:@"raw"]) {
        return true;
        
    } else if ([extension isEqualToString:@"nef"]) {
        return true;
        
    } else if ([extension isEqualToString:@"dng"]) {
        return true;
        
    } else if ([extension isEqualToString:@"cr2"]) {
        return true;
        
    } else if ([extension isEqualToString:@"tif"]) {
        return true;
    
    } else if ([extension isEqualToString:@"tiff"]) {
        return true;
        
    } else if ([extension isEqualToString:@"xmp"]) {
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

- (NSMutableArray*)contentForFolderAtPath:(NSString*)fullFolderPath {
    // Mutable array for missing elements
    NSMutableArray *missingElements = [NSMutableArray array];
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
        if (! [fileManager fileExistsAtPath:remoteFilePath]) {
            if ([self isPictureOrFolder:fileFullPath]) {
                MissingFile* missingFile = [[MissingFile alloc] initWithLocalFilePath:fileFullPath andRemoteFilePath:remoteFilePath];
                if ([fileManager fileExistsAtPath:fileFullPath isDirectory:&isDir] && isDir) {
                    [missingFile setChildren:[self contentForFolderAtPath:fileFullPath]];
                    [missingFile setIsFile:NO];
                }
                
                [missingElements addObject:missingFile];
                
            }
        }
        
    }
    return missingElements;
}

- (IBAction)scan:(id)sender {
    if (!remoteFolderFullPath || !localFolderFullPath) {
        [self setUserMessage:@"Please select local and remote folders!"];
        return;
    }
    [progressIndicator setHidden:false];
    [progressIndicator startAnimation:self];
    NSMutableArray *missings = [self contentForFolderAtPath:localFolderFullPath];
    [progressIndicator stopAnimation:self];
    [progressIndicator setHidden:true];
    
    [self setMissingFiles:missings];
    
    NSLog(@"%@", missingFiles);
    
}

- (IBAction)copySelected:(id)sender {
    [progressIndicator setHidden:false];
    [progressIndicator startAnimation:self];
    NSIndexPath *indexPath = [browser selectionIndexPath];
    MissingFile *next = [missingFiles objectAtIndex:[indexPath indexAtPosition:0]];
    for (NSInteger i=1; i<[indexPath length]; i++) {
        next = [[next children] objectAtIndex:[indexPath indexAtPosition:i]];
    }
    [next copyFile];
    [progressIndicator stopAnimation:self];
    [progressIndicator setHidden:true];
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
