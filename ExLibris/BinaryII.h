//
//  BinaryII.h
//  Disk II
//
//  Created by David Schweinsberg on 18/01/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PDFileEntry;

@interface BinaryII : NSObject {
}

+ (NSData *)encodeForFileEntry:(PDFileEntry *)fileEntry data:(NSData *)data;

@end
