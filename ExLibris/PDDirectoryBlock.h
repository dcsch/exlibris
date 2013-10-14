//
//  PDDirectoryBlock.h
//  Disk II
//
//  Created by David Schweinsberg on 2/01/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PDVolume;
@class PDDirectory;
@class PDFileEntry;

@interface PDDirectoryBlock : NSObject
{
    PDVolume *volume;
    PDDirectory *directory;
    NSMutableData *blockData;
    NSUInteger blockNumber;
    NSUInteger entriesPerBlock;
    NSUInteger entryLength;
    NSMutableArray *entries;
}

//@property(readonly) PDDirectory *directory;
@property NSUInteger blockNumber;
@property NSUInteger previousBlockNumber;
@property NSUInteger nextBlockNumber;
@property(readonly) NSUInteger entriesPerBlock;
@property(readonly) NSUInteger entryLength;
@property(strong, readonly) NSArray *entries;
@property(strong, readonly) NSData *data;

- (id)initWithVolume:(PDVolume *)aVolume
           directory:(PDDirectory *)aDirectory
         blockNumber:(NSUInteger)aBlockNumber;

- (id)initWithVolume:(PDVolume *)aVolume
           directory:(PDDirectory *)aDirectory
         blockNumber:(NSUInteger)aBlockNumber
     entriesPerBlock:(NSUInteger)count
         entryLength:(NSUInteger)length;

- (id)initWithVolume:(PDVolume *)aVolume
           directory:(PDDirectory *)aDirectory
         blockNumber:(NSUInteger)aBlockNumber
     nextBlockNumber:(NSUInteger)aNextBlockNumber
 previousBlockNumber:(NSUInteger)aPreviousBlockNumber
       directoryName:(NSString *)directoryName
       parentPointer:(NSUInteger)parentPointer
   parentEntryNumber:(NSUInteger)parentEntryNumber
   parentEntryLength:(NSUInteger)parentEntryLength;

- (NSInteger)findInactiveEntryIndex;

@end
