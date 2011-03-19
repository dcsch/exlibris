//
//  D3Volume.h
//  Disk II
//
//  Created by David Schweinsberg on 10/08/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Volume.h"

@class D3VTOC;
@class D3Catalog;
@class D3FileEntry;
@class D3TrackSector;

@interface D3Volume : Volume
{
    D3VTOC *vtoc;
    D3Catalog *catalog;
}

@property(readonly) NSUInteger number;

@property(retain, readonly) D3VTOC *vtoc;

@property(retain, readonly) D3Catalog *catalog;

- (id)initWithContainer:(NSObject *)aContainer
           blockStorage:(BlockStorage *)aBlockStorage;

- (NSData *)dataForTrackSector:(D3TrackSector *)aTrackSector;

- (NSData *)dataForEntry:(D3FileEntry *)entry;

@end
