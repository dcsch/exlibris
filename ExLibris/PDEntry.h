//
//  PDEntry.h
//  Disk II
//
//  Created by David Schweinsberg on 2/01/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import <Cocoa/Cocoa.h>

BOOL unpackDateAndTime(const unsigned char *data,
                       NSInteger *year,
                       NSInteger *month,
                       NSInteger *day,
                       NSInteger *hour,
                       NSInteger *minute);

BOOL packDateAndTime(unsigned char *data,
                     NSInteger year,
                     NSInteger month,
                     NSInteger day,
                     NSInteger hour,
                     NSInteger minute);

@class PDVolume;
@class PDDirectory;

@interface PDEntry : NSObject
{
    unsigned char *entryBytes;
    NSUInteger entryLength;
}

@property(weak, readonly) PDVolume *volume;
@property(strong) PDDirectory *parentDirectory;
@property(strong, readonly) PDEntry *parentEntry;

@property NSUInteger storageType;
@property(strong) NSString *fileName;
@property(readonly, copy) NSString *pathName;
@property(strong) NSDate *creationDateAndTime;
@property NSUInteger version;
@property NSUInteger minVersion;
@property NSUInteger access;
@property(weak, readonly) NSData *entryData;

- (id)initWithVolume:(PDVolume *)aVolume
     parentDirectory:(PDDirectory *)aDirectory
         parentEntry:(PDEntry *)aParentEntry
               bytes:(void *)anEntryBytes
              length:(NSUInteger)anEntryLength;

- (void)clear;

@end
