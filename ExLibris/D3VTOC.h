//
//  D3VTOC.h
//  Disk II
//
//  Created by David Schweinsberg on 10/08/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class D3Volume;

@interface D3VTOC : NSObject
{
    NSData *sectorData;
    NSUInteger catalogFirstTrackNumber;
    NSUInteger catalogFirstSectorNumber;
    NSUInteger dosRelease;
    NSUInteger volumeNumber;
    NSUInteger maxTrackSectorPairs;
    NSUInteger lastAllocatedTrack;
    NSInteger trackAllocationDirection;
    NSUInteger trackCount;
    NSUInteger sectorsPerTrackCount;
    NSUInteger bytesPerSectorCount;
}

@property(readonly) NSUInteger catalogFirstTrackNumber;

@property(readonly) NSUInteger catalogFirstSectorNumber;

@property(readonly) NSUInteger volumeNumber;

- (instancetype)initWithVolume:(D3Volume *)volume NS_DESIGNATED_INITIALIZER;
- (instancetype)init __attribute__((unavailable));

@end
