//
//  PDEntry+DiskII.h
//  Disk II
//
//  Created by David Schweinsberg on 29/04/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import "PDEntry.h"
#import <Cocoa/Cocoa.h>

@class PDFileType;
@class PDDirectory;

@interface PDEntry (DiskII)

@property(retain, readonly) PDFileType *fileType;
@property(readonly) NSUInteger keyPointer;
@property(readonly) NSUInteger blocksUsed;
@property(readonly) NSUInteger eof;
@property(readonly) NSUInteger auxType;
@property(retain, readonly) NSDate *lastMod;
@property(readonly) BOOL destroyEnabled;
@property(readonly) BOOL renameEnabled;
@property(readonly) BOOL backup;
@property(readonly) BOOL writeEnabled;
@property(readonly) BOOL readEnabled;

@property(retain, readonly) NSColor *textColor;

@property(retain, readonly) PDDirectory *directory;

@end
