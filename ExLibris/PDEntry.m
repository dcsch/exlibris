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
                       NSInteger *year,
                       NSInteger *month,
                       NSInteger *day,
                       NSInteger *hour,
                       NSInteger *minute)
{
    // ProDOS Tech Note 28 describes how to represent dates from 1940 to 2039
    int y = data[1] >> 1;
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
                     NSInteger year,
                     NSInteger month,
                     NSInteger day,
                     NSInteger hour,
                     NSInteger minute)
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


@interface PDEntry ()
{
    NSString *_fileName;
}

@end


@implementation PDEntry

- (instancetype)initWithVolume:(PDVolume *)aVolume
               parentDirectory:(PDDirectory *)aDirectory
                   parentEntry:(PDEntry *)aParentEntry
                         bytes:(void *)anEntryBytes
                        length:(NSUInteger)anEntryLength;
{
    self = [super init];
    if (self)
    {
        _volume = aVolume;
        self.parentDirectory = aDirectory;
        _parentEntry = aParentEntry;
        entryBytes = anEntryBytes;
        entryLength = anEntryLength;
    }
    return self;
}


- (void)clear
{
    memset(entryBytes, 0, entryLength);
    [self setValue:nil forKey:@"fileName"];
}

- (NSUInteger)storageType
{
    return entryBytes[0] >> 4;
}

- (void)setStorageType:(NSUInteger)aStorageType
{
    entryBytes[0] = (aStorageType << 4) | (entryBytes[0] & 0xf);
}

- (NSString *)fileName
{
    if (!_fileName)
    {
        // We'll cache the file name
        unsigned char nameLength = entryBytes[0] & 0xf;
        if (nameLength > 0)
            _fileName = [[NSString alloc] initWithBytes:entryBytes + 1
                                                 length:nameLength
                                               encoding:[NSString defaultCStringEncoding]];
        else
        {
            // The nameLength is zero, so this is likely to be an empty entry.
            // But is there a lingering filename from a deleted entry?
            if (entryBytes[1])
            {
                _fileName = [[NSString alloc] initWithBytes:entryBytes + 1
                                                     length:15
                                                   encoding:[NSString defaultCStringEncoding]];
            }
        }
    }
    return _fileName;
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
    
    _fileName = [aFileName copy];
}

- (NSString *)pathName
{
    // Build path from parent directories
    NSMutableArray *dirArray = [NSMutableArray array];
    PDDirectory *dir = _parentDirectory;
    while (dir)
    {
        [dirArray addObject:dir];
        if (dir.fileEntry)
            dir = dir.fileEntry.parentDirectory;
        else
            break;
    }
    
    NSMutableString *path = [NSMutableString string];
    for (NSInteger i = dirArray.count - 1; i >= 0; --i)
    {
        dir = dirArray[i];
        [path appendFormat:@"/%@", dir.name];
    }

    [path appendFormat:@"/%@", self.fileName];
    
    return path;
}

- (NSDate *)creationDateAndTime
{
    if (entryBytes[0x18] || entryBytes[0x19])
    {
        NSInteger year;
        NSInteger month;
        NSInteger day;
        NSInteger hour;
        NSInteger minute;
        if (unpackDateAndTime(entryBytes + 0x18,
                              &year,
                              &month,
                              &day,
                              &hour,
                              &minute))
        {
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

- (void)setCreationDateAndTime:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit
                                                   fromDate:date];
    packDateAndTime(entryBytes + 0x18,
                    dateComponents.year,
                    dateComponents.month,
                    dateComponents.day,
                    dateComponents.hour,
                    dateComponents.minute);
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
    NSScriptObjectSpecifier *containerSpec = _parentDirectory.objectSpecifier;
    return [[NSNameSpecifier alloc] initWithContainerClassDescription:containerSpec.keyClassDescription
                                                   containerSpecifier:containerSpec
                                                                  key:@"entry"
                                                                 name:self.fileName];
}

@end
