//
//  PDDirectoryHeader.h
//  Disk II
//
//  Created by David Schweinsberg on 3/01/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PDEntry.h"

@interface PDDirectoryHeader : PDEntry
{
}

@property NSUInteger entryLength;
@property NSUInteger entriesPerBlock;
@property NSUInteger fileCount;

// For volume directories
@property NSUInteger bitMapPointer;
@property NSUInteger totalBlocks;

// For subdirectories
@property NSUInteger parentPointer;
@property NSUInteger parentEntryNumber;
@property NSUInteger parentEntryLength;

@end
