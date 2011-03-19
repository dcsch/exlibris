//
//  PDEntry.m
//  Disk II
//
//  Created by David Schweinsberg on 2/01/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import "PDEntry.h"
#import "PDVolume.h"
#import "PDDirectory.h"
#import "PDFileEntry.h"

BOOL unpackDateAndTime(const unsigned char *data,
                       int *year,
                       unsigned int *month,
                       unsigned int *day,
                       unsigned int *hour,
                       unsigned int *minute)
{
    // ProDOS Tech Note 28 describes how to represent dates from 1940 to 2039
    unsigned int y = data[1] >> 1;
    if (40 <= y && y <= 99)
        *year = 1900 + y;
    else if (0 <= y && y <= 39)
        *year = 2000 + y;
    else
        return NO;
    *month  = ((data[1] & 0x01) << 3) | (data[0] >> 5);
    *day    = data[0] & 0x1f;
    *hour   = data[3] & 0x1f;
    *minute = data[2] & 0x3f;
    
//    NSLog(@"Date & Time: %02x %02x %02x %02x -> %x %x %x %x %x",
//          data[0],
//          data[1],
//          data[2],
//          data[3],
//          *year,
//          *month,
//          *day,
//          *hour,
//          *minute);
    return YES;
}

BOOL packDateAndTime(unsigned char *data,
                     int year,
                     unsigned int month,
                     unsigned int day,
                     unsigned int hour,
                     unsigned int minute)
{
    if (1940 <= year && year <= 1999)
        year -= 1900;
    else if (2000 <= year && year <= 2039)
        year -= 2000;
    else
        return NO;
    data[0] = ((month & 0x0f) << 5) | (day & 0x1f);
    data[1] = ((year & 0x7f) << 1) | ((month & 0x0f) >> 3);
    data[2] = (minute & 0x3f);
    data[3] = (hour & 0x1f);
    return YES;
}

@implementation PDEntry

- (id)initWithVolume:(PDVolume *)aVolume
     parentDirectory:(PDDirectory *)aDirectory
         parentEntry:(PDEntry *)aParentEntry
               bytes:(void *)anEntryBytes
              length:(NSUInteger)anEntryLength;
{
    self = [super init];
    if (self)
    {
        volume = aVolume;  // We won't retain this as it's owned by our parent
        self.parentDirectory = aDirectory;
        parentEntry = aParentEntry;
        entryBytes = anEntryBytes;
        entryLength = anEntryLength;
    }
    return self;
}

- (void)dealloc
{
    [parentDirectory release];
    [fileName release];
    [super dealloc];
}

- (void)clear
{
    memset(entryBytes, 0, entryLength);
}

@synthesize volume;

@synthesize parentDirectory;

@synthesize parentEntry;

- (NSUInteger)storageType
{
    return entryBytes[0] >> 4;
}

- (void)setStorageType:(NSUInteger)aStorageType
{
    entryBytes[0] |= (unsigned char)aStorageType << 4;
}

- (NSString *)fileName
{
    if (!fileName)
    {
        // We'll cache the file name
        unsigned char nameLength = entryBytes[0] & 0xf;
        if (nameLength > 0)
            fileName = [[NSString alloc] initWithBytes:entryBytes + 1
                                                length:nameLength
                                              encoding:[NSString defaultCStringEncoding]];
        else
        {
            // The nameLength is zero, so this is likely to be an empty entry.
            // But is there a lingering filename from a deleted entry?
            if (entryBytes[1])
            {
                fileName = [[NSString alloc] initWithBytes:entryBytes + 1
                                                    length:15
                                                  encoding:[NSString defaultCStringEncoding]];
            }
        }
    }
    return fileName;
}

- (void)setFileName:(NSString *)aFileName
{
    NSUInteger nameLength = MIN(15, aFileName.length);
    NSRange range = NSMakeRange(0, nameLength);
    entryBytes[0] &= 0xf0;
    entryBytes[0] |= nameLength;
    memset(entryBytes + 1, 0, 15);
    [aFileName getBytes:entryBytes + 1
              maxLength:15
             usedLength:&nameLength
               encoding:[NSString defaultCStringEncoding]
                options:0
                  range:range
         remainingRange:NULL];
    
    [fileName release];
    fileName = [aFileName copy];
}

- (NSString *)pathName
{
    // Build path from parent directories
    NSMutableArray *dirArray = [NSMutableArray array];
    PDDirectory *dir = parentDirectory;
    while (dir)
    {
        [dirArray addObject:dir];
        if (dir.fileEntry)
            dir = dir.fileEntry.parentDirectory;
        else
            break;
    }
    
    NSMutableString *path = [NSMutableString string];
    int i;
    for (i = dirArray.count - 1; i >= 0; --i)
    {
        dir = [dirArray objectAtIndex:i];
        [path appendFormat:@"/%@", dir.name];
    }

    [path appendFormat:@"/%@", self.fileName];
    
    return path;
}

- (NSCalendarDate *)creationDateAndTime
{
    if (entryBytes[0x18] || entryBytes[0x19])
    {
        int year;
        unsigned int month;
        unsigned int day;
        unsigned int hour;
        unsigned int minute;
        if (unpackDateAndTime(entryBytes + 0x18,
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

- (void)setCreationDateAndTime:(NSCalendarDate *)aDate
{
    packDateAndTime(entryBytes + 0x18,
                    aDate.yearOfCommonEra,
                    aDate.monthOfYear,
                    aDate.dayOfMonth,
                    aDate.hourOfDay,
                    aDate.minuteOfHour);
}

- (NSUInteger)version
{
    return entryBytes[0x1c];
}

- (void)setVersion:(NSUInteger)aVersion
{
    entryBytes[0x1c] = (unsigned char)aVersion;
}

- (NSUInteger)minVersion
{
    return entryBytes[0x1d];
}

- (void)setMinVersion:(NSUInteger)aMinVersion
{
    entryBytes[0x1d] = (unsigned char)aMinVersion;
}

- (NSUInteger)access
{
    return entryBytes[0x1e];
}

- (void)setAccess:(NSUInteger)aAccess
{
    entryBytes[0x1e] = (unsigned char)aAccess;
}

- (NSData *)entryData
{
    return [NSData dataWithBytes:entryBytes length:entryLength];
}

- (id)valueForUndefinedKey:(NSString *)key
{
    return nil;
}

- (NSScriptObjectSpecifier *)objectSpecifier
{
    NSScriptObjectSpecifier *containerSpec = parentDirectory.objectSpecifier;
    return [[NSNameSpecifier alloc] initWithContainerClassDescription:containerSpec.keyClassDescription
                                                   containerSpecifier:containerSpec
                                                                  key:@"entry"
                                                                 name:self.fileName];
}

@end
