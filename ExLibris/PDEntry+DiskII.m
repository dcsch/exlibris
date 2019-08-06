//
//  PDEntry+DiskII.m
//  Disk II
//
//  Created by David Schweinsberg on 29/04/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import "PDEntry+DiskII.h"
//#import "PDFileType.h"

@implementation PDEntry (DiskII)

- (PDFileType *)fileType {
  return nil;
}

- (NSUInteger)keyPointer {
  return 0;
}

- (NSUInteger)blocksUsed {
  return 0;
}

- (NSUInteger)eof {
  return 0;
}

- (NSUInteger)auxType {
  return 0;
}

- (NSDate *)lastMod {
  return nil;
}

- (BOOL)destroyEnabled {
  return (self.access & 0x80) ? YES : NO;
}

- (BOOL)renameEnabled {
  return (self.access & 0x40) ? YES : NO;
}

- (BOOL)backup {
  return (self.access & 0x20) ? YES : NO;
}

- (BOOL)writeEnabled {
  return (self.access & 0x02) ? YES : NO;
}

- (BOOL)readEnabled {
  return (self.access & 0x01) ? YES : NO;
}

- (NSColor *)textColor {
  return [NSColor grayColor];
}

- (PDDirectory *)directory {
  return nil;
}

@end
