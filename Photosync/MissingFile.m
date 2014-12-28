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
        [self setFilepath:local];
        [self setRemoteFilePath:remote];
        NSArray *components = [local pathComponents];
        filename = [components objectAtIndex:[components count]-1];
    }
    return self;
}

- (BOOL)copyFile {
    if (self.isMissing) {
        NSError *error;
        NSFileManager *filemanager = [NSFileManager defaultManager];
        if (![filemanager copyItemAtPath:self.filepath toPath:self.remoteFilePath error:&error]) {
            NSLog(@"There was an error while copying");
            return false;
        } else {
            [self setIsMissing:NO];
            return true;
        }
    }
    return false;
}

- (NSString*)description {
    return self.filepath;
}

@end
