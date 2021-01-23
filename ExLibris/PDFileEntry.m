//
//  PDFileEntry.m
//  Disk II
//
//  Created by David Schweinsberg on 3/01/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import "PDFileEntry.h"
#import "PDDirectory.h"
#import "PDDirectoryBlock.h"
#import "PDEntry.h"
#import "PDFileType.h"

@interface PDFileEntry () {
  PDDirectory *_directory;
  PDFileType *_fileType;
}

@end

@implementation PDFileEntry

- (instancetype)initWithVolume:(PDVolume *)aVolume
               parentDirectory:(PDDirectory *)aDirectory
                   parentEntry:(PDEntry *)aParentEntry
                         bytes:(void *)anEntryBytes
                        length:(NSUInteger)anEntryLength {
  self = [super initWithVolume:aVolume
               parentDirectory:aDirectory
                   parentEntry:aParentEntry
                         bytes:anEntryBytes
                        length:anEntryLength];
  if (self) {
    if (self.fileType.typeId == DIRECTORY_FILE_TYPE_ID)
      [self updateDirectory];
  }
  return self;
}

//- (NSString *)description
//{
//}

- (PDFileType *)fileType {
  NSUInteger typeId = entryBytes[0x10];
  if (_fileType && (_fileType.typeId != typeId)) {
    _fileType = nil;
  }
  if (!_fileType) {
    _fileType = [PDFileType fileTypeWithId:entryBytes[0x10]];
  }
  return _fileType;
}

- (void)setFileType:(PDFileType *)aFileType {
  _fileType = aFileType;
  entryBytes[0x10] = (unsigned char)_fileType.typeId;
}

- (NSUInteger)keyPointer {
  return (entryBytes[0x12] << 8) | entryBytes[0x11];
}

- (void)setKeyPointer:(NSUInteger)pointer {
  entryBytes[0x11] = (unsigned char)pointer;
  entryBytes[0x12] = (unsigned char)(pointer >> 8);
}

- (NSUInteger)blocksUsed {
  return (entryBytes[0x14] << 8) | entryBytes[0x13];
}

- (void)setBlocksUsed:(NSUInteger)blockCount {
  entryBytes[0x13] = (unsigned char)blockCount;
  entryBytes[0x14] = (unsigned char)(blockCount >> 8);
}

- (NSUInteger)eof {
  return (entryBytes[0x17] << 16) | (entryBytes[0x16] << 8) | entryBytes[0x15];
}

- (void)setEof:(NSUInteger)eof {
  entryBytes[0x15] = (unsigned char)eof;
  entryBytes[0x16] = (unsigned char)(eof >> 8);
  entryBytes[0x17] = (unsigned char)(eof >> 16);
}

- (NSUInteger)auxType {
  return (entryBytes[0x20] << 8) | entryBytes[0x1f];
}

- (void)setAuxType:(NSUInteger)auxType {
  entryBytes[0x1f] = (unsigned char)auxType;
  entryBytes[0x20] = (unsigned char)(auxType >> 8);
}

- (NSDate *)lastMod {
  if (entryBytes[0x21] || entryBytes[0x22]) {
    NSInteger year;
    NSInteger month;
    NSInteger day;
    NSInteger hour;
    NSInteger minute;
    if (unpackDateAndTime(entryBytes + 0x21, &year, &month, &day, &hour,
                          &minute)) {
      NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
      dateComponents.year = year;
      dateComponents.month = month;
      dateComponents.day = day;
      dateComponents.hour = hour;
      dateComponents.minute = minute;
      dateComponents.timeZone = [NSTimeZone systemTimeZone];
      return [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
    }
  }
  return nil;
}

- (void)setLastMod:(NSDate *)date {
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSDateComponents *dateComponents = [calendar
      components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |
                 NSCalendarUnitHour | NSCalendarUnitMinute
        fromDate:date];
  packDateAndTime(entryBytes + 0x18, dateComponents.year, dateComponents.month,
                  dateComponents.day, dateComponents.hour,
                  dateComponents.minute);
}

- (NSUInteger)headerPointer {
  return (entryBytes[0x26] << 8) | entryBytes[0x25];
}

- (void)setHeaderPointer:(NSUInteger)headerPointer {
  entryBytes[0x25] = (unsigned char)headerPointer;
  entryBytes[0x26] = (unsigned char)(headerPointer >> 8);
}

- (PDDirectory *)directory {
  if (self.fileType.typeId == 0x0f) {
    //        NSAssert(_directory != nil,
    //                 @"Directory file entry has a nil directory object");
  }

  return _directory;
}

- (void)updateDirectory {
  //    NSAssert(self.fileType.typeId == 0x0f, @"Trying to update a directory on
  //    a non-directory file entry");

  if (self.fileType.typeId == 0x0f)
    [self setValue:[[PDDirectory alloc] initWithFileEntry:self]
            forKey:@"directory"];
  else
    [self setValue:nil forKey:@"directory"];
}

@end
