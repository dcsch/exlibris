//
//  D3TrackSector.h
//  Disk II
//
//  Created by David Schweinsberg on 12/08/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface D3TrackSector : NSObject
{
    NSUInteger track;
    NSUInteger sector;
}

@property(readonly) NSUInteger track;

@property(readonly) NSUInteger sector;

+ (id)track:(NSUInteger)aTrack sector:(NSUInteger)aSector;

- (id)initWithTrack:(NSUInteger)aTrack sector:(NSUInteger)aSector;

@end
