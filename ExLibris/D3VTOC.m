//
//  D3VTOC.m
//  Disk II
//
//  Created by David Schweinsberg on 10/08/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import "D3VTOC.h"
#import "D3Volume.h"
#import "D3TrackSector.h"
#import "DiskII.h"

@implementation D3VTOC

- (id)initWithVolume:(D3Volume *)volume
{
    self = [super init];
    if (self)
    {
        sectorData = [[volume dataForTrackSector:[D3TrackSector track:17 sector:0]] retain];
        
        const unsigned char *ptr = [sectorData bytes];
        catalogFirstTrackNumber = ptr[1];
        catalogFirstSectorNumber = ptr[2];
        dosRelease = ptr[3];
        volumeNumber = ptr[6];
        maxTrackSectorPairs = ptr[0x27];
        lastAllocatedTrack = ptr[0x30];
        trackAllocationDirection = (const char) ptr[0x31];
        trackCount = ptr[0x34];
        sectorsPerTrackCount = ptr[0x35];
        bytesPerSectorCount = unpackWord(ptr + 0x36);
        
        // Is this a valid DOS 3.x volume?
        if (dosRelease > 3
            || (trackAllocationDirection != -1 && trackAllocationDirection != 1)
            || trackCount > 50
            || sectorsPerTrackCount > 32
            || bytesPerSectorCount > 256)
        {
            [self release];
            self = nil;
        }
    }
    return self;
}

- (void)dealloc
{
    [sectorData release];
    [super dealloc];
}

@synthesize volumeNumber;

@synthesize catalogFirstTrackNumber;

@synthesize catalogFirstSectorNumber;

@end
