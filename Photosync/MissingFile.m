//
//  MissingFile.m
//  Photosync
//
//  Created by dominique on 26.12.14.
//  Copyright (c) 2014 dominique. All rights reserved.
//

#import "MissingFile.h"

@implementation MissingFile

@synthesize isSelected, isActive;
@synthesize filepath;
@synthesize remoteFilePath;
@synthesize fileExtension;

- (id) init {
    self = [super init];
    if (self) {
        isActive = true;
    }
    return self;
}

- (BOOL)copyFile {
    if (self.isSelected && self.isActive) {
        NSError *error;
        NSFileManager *filemanager = [NSFileManager defaultManager];
        if (![filemanager copyItemAtPath:self.filepath toPath:self.remoteFilePath error:&error]) {
            NSLog(@"There was an error while copying");
            return false;
        } else {
            [self setIsActive:false];
            [self setIsSelected:false];
            return true;
        }
    }
    return false;
}

@end
