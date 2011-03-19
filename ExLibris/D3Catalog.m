//
//  D3Catalog.m
//  Disk II
//
//  Created by David Schweinsberg on 10/08/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import "D3Catalog.h"
#import "D3Volume.h"
#import "D3VTOC.h"
#import "D3FileEntry.h"
#import "D3TrackSector.h"

@implementation D3Catalog

- (id)initWithVolume:(D3Volume *)volume
{
    self = [super init];
    if (self)
    {
        sectors = [[NSMutableArray alloc] init];
        entries = [[NSMutableArray alloc] init];

        // Iterate through the catalog sectors, loading all entries
        NSUInteger track = volume.vtoc.catalogFirstTrackNumber;
        NSUInteger sector = volume.vtoc.catalogFirstSectorNumber;
        while (track)
        {
            NSData *sectorData = [volume dataForTrackSector:[D3TrackSector track:track sector:sector]];
            [sectors addObject:sectorData];
            const unsigned char *ptr = [sectorData bytes];
            
            // The next track/sector
            track = ptr[1];
            sector = ptr[2];
            
            ptr += 0xb;
            int i;
            for (i = 0; i < 7; ++i)
            {
                if (ptr[0])
                {
                    D3FileEntry *entry = [[D3FileEntry alloc] initWithBytes:ptr];
                    [entries addObject:entry];
                    NSLog(@"File entry: '%@'", entry.fileName);
                }
                ptr += 0x23;
            }
        }
    }
    return self;
}

- (void)dealloc
{
    [entries release];
    [sectors release];
    [super dealloc];
}

@synthesize entries;

@end
