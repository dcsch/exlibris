//
//  D3FileEntry.h
//  Disk II
//
//  Created by David Schweinsberg on 10/08/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define TEXT_FILE            0x00
#define INTEGER_BASIC_FILE   0x01
#define APPLESOFT_BASIC_FILE 0x02
#define BINARY_FILE          0x04
#define S_TYPE_FILE          0x08
#define RELOCATABLE_FILE     0x10
#define A_TYPE_FILE          0x20
#define B_TYPE_FILE          0x40

@class D3TrackSector;

@interface D3FileEntry : NSObject
{
    const unsigned char *entryBytes;
    D3TrackSector *firstTrackSectorList;
    NSString *fileName;
}

@property(readonly) BOOL deleted;

@property(weak, readonly)  D3TrackSector *firstTrackSectorList;

@property(readonly) BOOL locked;

@property(readonly) NSUInteger fileType;

@property(copy, readonly) NSString *fileName;

@property(readonly) NSUInteger sectorsUsed;

- (instancetype)initWithBytes:(const void *)bytes NS_DESIGNATED_INITIALIZER;
- (instancetype)init __attribute__((unavailable));

@end
