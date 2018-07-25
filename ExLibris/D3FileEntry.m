//
//  D3FileEntry.m
//  Disk II
//
//  Created by David Schweinsberg on 10/08/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import "D3FileEntry.h"
#import "D3TrackSector.h"
#import "DiskII.h"

@implementation D3FileEntry

- (instancetype)initWithBytes:(const void *)bytes
{
    self = [super init];
    if (self)
    {
        entryBytes = bytes;
    }
    return self;
}


- (BOOL)deleted
{
    return (entryBytes[0] == 0xff) ? YES : NO;
}

- (D3TrackSector *)firstTrackSectorList
{
    if (!firstTrackSectorList)
    {
        NSUInteger track;
        if (self.deleted)
            track = entryBytes[0x20];
        else
            track = entryBytes[0];
        firstTrackSectorList =
        [[D3TrackSector alloc] initWithTrack:track
                                      sector:entryBytes[1]];
    }
    return firstTrackSectorList;
}

- (BOOL)locked
{
    return ((entryBytes[2] & 0x80) == 0x80) ? YES : NO;
}

- (NSUInteger)fileType
{
    return entryBytes[2] & 0x7f;
}

- (NSString *)fileName
{
    if (!fileName)
    {
        // We'll cache the file name
        char str[30];
        int i = 0;
        int lastNonSpace = 0;
        int len = self.deleted ? 29 : 30;
        for (i = 0; i < len; ++i)
        {
            str[i] = entryBytes[i + 3] - 0x80;
            if (str[i] != 0x20)
                lastNonSpace = i;
        }
        fileName = [[NSString alloc] initWithBytes:str
                                            length:lastNonSpace + 1
                                          encoding:[NSString defaultCStringEncoding]];
    }
    return fileName;
}

- (NSUInteger)sectorsUsed
{
    return unpackWord(entryBytes + 0x21);
}

@end
