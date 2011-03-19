//
//  D3TrackSector.m
//  Disk II
//
//  Created by David Schweinsberg on 12/08/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import "D3TrackSector.h"


@implementation D3TrackSector

+ (id)track:(NSUInteger)aTrack sector:(NSUInteger)aSector
{
    return [[[D3TrackSector alloc] initWithTrack:aTrack sector:aSector] autorelease];
}

- (id)initWithTrack:(NSUInteger)aTrack sector:(NSUInteger)aSector
{
    self = [super init];
    if (self)
    {
        track = aTrack;
        sector = aSector;
    }
    return self;
}

@synthesize track;

@synthesize sector;

@end
