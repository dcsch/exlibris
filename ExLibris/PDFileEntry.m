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
#import "PDFileType.h"

@implementation PDFileEntry

- (id)initWithVolume:(PDVolume *)aVolume
     parentDirectory:(PDDirectory *)aDirectory
         parentEntry:(PDEntry *)aParentEntry
               bytes:(void *)anEntryBytes
              length:(NSUInteger)anEntryLength
{
    self = [super initWithVolume:aVolume
                 parentDirectory:aDirectory
                     parentEntry:aParentEntry
                           bytes:anEntryBytes
                          length:anEntryLength];
    if (self)
    {
    }
    return self;
}

- (void)dealloc
{
    [directory release];
    [fileType release];
    [super dealloc];
}

//- (NSString *)description
//{
//}

- (PDFileType *)fileType
{
    NSUInteger typeId = entryBytes[0x10];
    if (fileType && (fileType.typeId != typeId))
    {
        [fileType release];
        fileType = nil;
    }
    if (!fileType)
    {
        fileType = [PDFileType fileTypeWithId:entryBytes[0x10]];
        [fileType retain];
    }
    return fileType;
}

- (void)setFileType:(PDFileType *)aFileType
{
    [aFileType retain];
    [fileType release];
    fileType = aFileType;
    entryBytes[0x10] = (unsigned char)fileType.typeId;
}

- (NSUInteger)keyPointer
{
    return (entryBytes[0x12] << 8) | entryBytes[0x11];
}

- (void)setKeyPointer:(NSUInteger)pointer
{
    entryBytes[0x11] = (unsigned char)pointer;
    entryBytes[0x12] = (unsigned char)(pointer >> 8);
}

- (NSUInteger)blocksUsed
{
    return (entryBytes[0x14] << 8) | entryBytes[0x13];
}

- (void)setBlocksUsed:(NSUInteger)blockCount
{
    entryBytes[0x13] = (unsigned char)blockCount;
    entryBytes[0x14] = (unsigned char)(blockCount >> 8);
}

- (NSUInteger)eof
{
    return (entryBytes[0x17] << 16) | (entryBytes[0x16] << 8) | entryBytes[0x15];
}

- (void)setEof:(NSUInteger)eof
{
    entryBytes[0x15] = (unsigned char)eof;
    entryBytes[0x16] = (unsigned char)(eof >> 8);
    entryBytes[0x17] = (unsigned char)(eof >> 16);
}

- (NSUInteger)auxType
{
    return (entryBytes[0x20] << 8) | entryBytes[0x1f];
}

- (void)setAuxType:(NSUInteger)auxType
{
    entryBytes[0x1f] = (unsigned char)auxType;
    entryBytes[0x20] = (unsigned char)(auxType >> 8);
}

- (NSCalendarDate *)lastMod
{
    if (entryBytes[0x21] || entryBytes[0x22])
    {
        int year;
        unsigned int month;
        unsigned int day;
        unsigned int hour;
        unsigned int minute;
        if (unpackDateAndTime(entryBytes + 0x21,
                              &year,
                              &month,
                              &day,
                              &hour,
                              &minute))
            return [NSCalendarDate dateWithYear:year
                                          month:month
                                            day:day
                                           hour:hour
                                         minute:minute
                                         second:0
                                       timeZone:[NSTimeZone systemTimeZone]];
    }
    return nil;
}

- (void)setLastMod:(NSCalendarDate *)date
{
    packDateAndTime(entryBytes + 0x21,
                    date.yearOfCommonEra,
                    date.monthOfYear,
                    date.dayOfMonth,
                    date.hourOfDay,
                    date.minuteOfHour);
}

- (NSUInteger)headerPointer
{
    return (entryBytes[0x26] << 8) | entryBytes[0x25];
}

- (void)setHeaderPointer:(NSUInteger)headerPointer
{
    entryBytes[0x25] = (unsigned char)headerPointer;
    entryBytes[0x26] = (unsigned char)(headerPointer >> 8);
}

- (PDDirectory *)directory
{
    // If this file type isn't a directory, then we can never return one
    if (self.fileType.typeId != 0x0f)
        return nil;

    // If we haven't initialised one, do it now
    if (!directory)
        directory = [[PDDirectory alloc] initWithFileEntry:self];
    return directory;
}

@end
