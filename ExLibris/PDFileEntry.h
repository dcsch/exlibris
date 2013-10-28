//
//  PDFileEntry.h
//  Disk II
//
//  Created by David Schweinsberg on 3/01/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PDEntry.h"

@class PDDirectory;
@class PDFileType;

@interface PDFileEntry : PDEntry

@property(strong) PDFileType *fileType;
@property NSUInteger keyPointer;
@property NSUInteger blocksUsed;
@property NSUInteger eof;
@property NSUInteger auxType;
@property(strong) NSDate *lastMod;
@property NSUInteger headerPointer;
@property(strong, readonly) PDDirectory *directory;

- (void)updateDirectory;

@end
