//
//  MissingFile.h
//  Photosync
//
//  Created by dominique on 26.12.14.
//  Copyright (c) 2014 dominique. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MissingFile : NSObject {
    NSArray *children;
    NSString *filepath, *filename;
    BOOL isMissing;
    NSInteger numberOfMissingFiles;
    id delegate;
}

@property BOOL isSelected;
@property BOOL isActive;
@property BOOL isFile;
@property BOOL isMissing;
@property NSString* filepath;
@property NSString* filename;
@property NSString* remoteFilePath;
@property NSString* fileExtension;
@property NSArray *children;
@property NSInteger numberOfMissingFiles;
@property id delegate;

- (id) initWithLocalFilePath:(NSString*)local andRemoteFilePath:(NSString*)remote;
- (BOOL)copyFile;
- (NSString*)description;
- (void)calculateNumberOfMissingFiles;
- (NSDictionary*)fileSize;

@end
