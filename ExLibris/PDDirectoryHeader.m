//
//  PDDirectoryHeader.m
//  Disk II
//
//  Created by David Schweinsberg on 3/01/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import "PDDirectoryHeader.h"
#import "DiskII.h"

@implementation PDDirectoryHeader

- (NSUInteger)entryLength {
  return entryBytes[0x1f];
}

- (void)setEntryLength:(NSUInteger)aEntryLength {
  entryBytes[0x1f] = (unsigned char)aEntryLength;
}

- (NSUInteger)entriesPerBlock {
  return entryBytes[0x20];
}

- (void)setEntriesPerBlock:(NSUInteger)entriesPerBlock {
  entryBytes[0x20] = (unsigned char)entriesPerBlock;
}

- (NSUInteger)fileCount {
  return (entryBytes[0x22] << 8) | entryBytes[0x21];
}

- (void)setFileCount:(NSUInteger)fileCount {
  packWord(entryBytes + 0x21, (unsigned short)fileCount);
}

- (NSUInteger)bitMapPointer {
  return unpackWord(entryBytes + 0x23);
}

- (void)setBitMapPointer:(NSUInteger)bitMapPointer {
  packWord(entryBytes + 0x23, (unsigned short)bitMapPointer);
}

- (NSUInteger)totalBlocks {
  return unpackWord(entryBytes + 0x25);
}

- (void)setTotalBlocks:(NSUInteger)totalBlocks {
  packWord(entryBytes + 0x25, (unsigned short)totalBlocks);
}

- (NSUInteger)parentPointer {
  return unpackWord(entryBytes + 0x23);
}

- (void)setParentPointer:(NSUInteger)parentPointer {
  packWord(entryBytes + 0x23, (unsigned short)parentPointer);
}

- (NSUInteger)parentEntryNumber {
  return entryBytes[0x25];
}

- (void)setParentEntryNumber:(NSUInteger)parentEntryNumber {
  entryBytes[0x25] = (unsigned char)parentEntryNumber;
}

- (NSUInteger)parentEntryLength {
  return entryBytes[0x26];
}

- (void)setParentEntryLength:(NSUInteger)parentEntryLength {
  entryBytes[0x26] = (unsigned char)parentEntryLength;
}

@end
