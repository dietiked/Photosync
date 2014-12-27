//
//  MissingFile.h
//  Photosync
//
//  Created by dominique on 26.12.14.
//  Copyright (c) 2014 dominique. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MissingFile : NSObject

@property BOOL isSelected;
@property BOOL isActive;
@property NSString* filepath;
@property NSString* remoteFilePath;
@property NSString* fileExtension;

- (BOOL)copyFile;

@end
