//
//  D3Volume.m
//  Disk II
//
//  Created by David Schweinsberg on 10/08/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import "D3Volume.h"
#import "BlockStorage.h"
#import "D3VTOC.h"
#import "D3Catalog.h"
#import "D3FileEntry.h"
#import "D3TrackSector.h"
#import "DiskII.h"

@implementation D3Volume

- (id)initWithContainer:(NSObject *)aContainer
           blockStorage:(BlockStorage *)aBlockStorage
{
    self = [super initWithContainer:aContainer blockStorage:aBlockStorage];
    if (self)
    {
        blockStorage.blockSize = 256;

        vtoc = [[D3VTOC alloc] initWithVolume:self];
        if (vtoc)
            catalog = [[D3Catalog alloc] initWithVolume:self];
        else
        {
            // If there is no valid VTOC, then this isn't a DOS 3.x volume
            self = nil;
        }
    }
    return self;
}


- (NSString *)name
{
    return [NSString stringWithFormat:@"Volume %lu", (unsigned long)self.number];
}

- (NSUInteger)number
{
    return vtoc.volumeNumber;
}

- (NSData *)dataForTrackSector:(D3TrackSector *)aTrackSector
{
    NSUInteger sectorIndex = 16 * aTrackSector.track + aTrackSector.sector;
    return [blockStorage mutableDataForBlock:sectorIndex];
}

- (NSData *)dataForEntry:(D3FileEntry *)entry
{
    [blockStorage open];

    // Load the track/sector lists
    D3TrackSector *trackSectorList = entry.firstTrackSectorList;
    NSData *trackSectorListData = [self dataForTrackSector:trackSectorList];
    NSMutableArray *trackSectorArray = [NSMutableArray array];
    NSUInteger nextTrack;
    NSUInteger nextSector;
    NSUInteger sectorOffset;
    do
    {
        const unsigned char *ptr = trackSectorListData.bytes;
        nextTrack = ptr[1];
        nextSector = ptr[2];
        sectorOffset = unpackWord(ptr + 5);
        
        int i;
        for (i = 0x0c; (i < 0xff) && ptr[i]; i += 2)
        {
            [trackSectorArray addObject:[D3TrackSector track:ptr[i] sector:ptr[i + 1]]];
        }
    }
    while (nextTrack);

    NSMutableData *entryData = [NSMutableData dataWithCapacity:256 * trackSectorArray.count];
    for (D3TrackSector *ts in trackSectorArray)
        [entryData appendData:[self dataForTrackSector:ts]];
    
    [blockStorage close];
    
    return entryData;
}

@synthesize vtoc;

@synthesize catalog;

@end
