//
//  PDEntry.h
//  Disk II
//
//  Created by David Schweinsberg on 2/01/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import <Cocoa/Cocoa.h>

BOOL unpackDateAndTime(const unsigned char *data,
                       int *year,
                       unsigned int *month,
                       unsigned int *day,
                       unsigned int *hour,
                       unsigned int *minute);

@class PDVolume;
@class PDDirectory;

@interface PDEntry : NSObject
{
    PDVolume *volume;
    PDDirectory *parentDirectory;
    PDEntry *parentEntry;
    unsigned char *entryBytes;
    NSUInteger entryLength;
    NSString *fileName;
}

@property(retain, readonly) PDVolume *volume;
@property(retain) PDDirectory *parentDirectory;
@property(retain, readonly) PDEntry *parentEntry;

@property NSUInteger storageType;
@property(retain) NSString *fileName;
@property(readonly, copy) NSString *pathName;
@property(retain) NSCalendarDate *creationDateAndTime;
@property NSUInteger version;
@property NSUInteger minVersion;
@property NSUInteger access;
@property(readonly) NSData *entryData;

- (id)initWithVolume:(PDVolume *)aVolume
     parentDirectory:(PDDirectory *)aDirectory
         parentEntry:(PDEntry *)aParentEntry
               bytes:(void *)anEntryBytes
              length:(NSUInteger)anEntryLength;

- (void)clear;

@end
