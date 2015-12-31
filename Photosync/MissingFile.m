//
//  MissingFile.m
//  Photosync
//
//  Created by dominique on 26.12.14.
//  Copyright (c) 2014 dominique. All rights reserved.
//

#import "MissingFile.h"

@implementation MissingFile

@synthesize isSelected, isActive, isFile, isMissing;
@synthesize filepath, filename;
@synthesize remoteFilePath;
@synthesize fileExtension;
@synthesize children;
@synthesize numberOfMissingFiles;
@synthesize delegate;

- (id) init {
    self = [super init];
    if (self) {
        isActive = true;
        isSelected = false;
        isFile = true;
    }
    return self;
}

- (id) initWithLocalFilePath:(NSString*)local andRemoteFilePath:(NSString*)remote {
    self = [super init];
    if (self) {
        isActive = true;
        isSelected = false;
        isFile = true;
        isMissing = YES;
        numberOfMissingFiles = 1;
        [self setFilepath:local];
        [self setRemoteFilePath:remote];
        NSArray *components = [local pathComponents];
        filename = [components objectAtIndex:[components count]-1];
    }
    return self;
}

- (BOOL)copyFile {
    //if (self.isMissing) {
        NSError *error;
        NSFileManager *filemanager = [NSFileManager defaultManager];
        BOOL isDir;
        // Check if folder exists
        if ([filemanager fileExistsAtPath:self.remoteFilePath isDirectory:&isDir] && isDir) {
            // Loop over children to copy them
            for (NSInteger i=0; i<[self.children count]; i++) {
                MissingFile *aFile = (MissingFile*)[self.children objectAtIndex:i];
                [aFile copyFile];
            }
        }
        if (![filemanager copyItemAtPath:self.filepath toPath:self.remoteFilePath error:&error]) {
            NSLog(@"There was an error while copying");
            return false;
        } else {
            [self setIsMissing:NO];
            return true;
        }
    //}
    return false;
}

- (NSString*)description {
    /*
    NSString *descr = @"";
    if (self.isFile) {
        descr = self.filename;
    } else {
        descr = [NSString stringWithFormat:@"%@ (%li)", self.filename, (long)self.numberOfMissingFiles];
    }
    return descr; 
    */
    return self.filename;
}

- (NSInteger)countNumberOfMissingFiles:(NSArray*)childrenArray {
    NSInteger numberOfmissingFiles = 0;
    for (NSInteger i=0; i<[childrenArray count]; i++) {
        MissingFile *file = [childrenArray objectAtIndex:i];
        if (file.isFile) {
            numberOfmissingFiles +=1;
        } else {
            numberOfmissingFiles += [self countNumberOfMissingFiles:file.children];
            [file setNumberOfMissingFiles:[self countNumberOfMissingFiles:file.children]];
        }
    }
    return numberOfmissingFiles;
}

- (void)calculateNumberOfMissingFiles {
    if (! self.isFile) {
        [self setNumberOfMissingFiles:[self countNumberOfMissingFiles:self.children]];
    }
}

- (NSDictionary*)sizeOfFile:(MissingFile*)file {
    unsigned long long sizeLocal = 0;
    unsigned long long sizeRemote = 0;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (file.isFile) {
        sizeLocal = [[fileManager attributesOfItemAtPath:self.filepath error:nil] fileSize];
        sizeRemote = [[fileManager attributesOfItemAtPath:self.remoteFilePath error:nil] fileSize];
    } else if (! file.isFile) { // Directory
        for (NSInteger i=0; i<[file.children count]; i++) {
            MissingFile *subfile = [file.children objectAtIndex:i];
            NSDictionary *fileSize = [subfile fileSize];
            sizeLocal += [[fileSize objectForKey:@"sizeLocal"] unsignedLongLongValue];
            sizeRemote += [[fileSize objectForKey:@"sizeRemote"] unsignedLongLongValue];
        }
    }
    NSNumber *local = [NSNumber numberWithUnsignedLongLong:sizeLocal];
    NSNumber *remote = [NSNumber numberWithUnsignedLongLong:sizeRemote];
    NSArray *objs = [NSArray arrayWithObjects:local, remote, nil];
    NSArray *keys = [NSArray arrayWithObjects:@"sizeLocal", @"sizeRemote", nil];
    return [NSDictionary dictionaryWithObjects:objs forKeys:keys];
}

- (NSDictionary*)fileSize {
    return [self sizeOfFile:self];
}

@end
