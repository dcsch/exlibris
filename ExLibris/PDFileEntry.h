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
{
    PDDirectory *directory;
    PDFileType *fileType;
}

@property(retain) PDFileType *fileType;
@property NSUInteger keyPointer;
@property NSUInteger blocksUsed;
@property NSUInteger eof;
@property NSUInteger auxType;
@property(retain) NSCalendarDate *lastMod;
@property NSUInteger headerPointer;
@property(retain, readonly) PDDirectory *directory;

@end
