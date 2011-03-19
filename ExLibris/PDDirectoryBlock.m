//
//  PDDirectoryBlock.m
//  Disk II
//
//  Created by David Schweinsberg on 2/01/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import "PDDirectoryBlock.h"
#import "PDDirectoryHeader.h"
#import "PDFileEntry.h"
#import "PDVolume.h"
#import "PDDirectory.h"
#import "BlockStorage.h"
#import "DiskImage.h"
#import "DiskII.h"

@implementation PDDirectoryBlock

- (id)initWithVolume:(PDVolume *)aVolume
           directory:(PDDirectory *)aDirectory
         blockNumber:(NSUInteger)aBlockNumber
{
    self = [super init];
    if (self)
    {
        volume = aVolume;
        directory = aDirectory;
        blockNumber = aBlockNumber;

        if (!blockData)
            blockData = [volume.blockStorage mutableDataForBlock:blockNumber];

        // Are the block numbers sensible?  If not, then this is unlikely
        // to be a ProDOS volume, in which case we'll fail.
        if (blockNumber == 2)
        {
            // This is supposed to be the key volume directory block, so we'd
            // expect the previous block to be 0 and the next block to be 3.
            if ((self.previousBlockNumber != 0) || (self.nextBlockNumber != 3))
                return nil;
        }

        // We're good to continue, so start making some commitments
        [blockData retain];
        entries = [[NSMutableArray alloc] init];
            
        unsigned char *ptr = blockData.mutableBytes;
        ptr += 4;  // Skip over previous and next block pointers
        NSUInteger i = 0;
        do
        {
            NSUInteger storageType = *ptr >> 4;
            PDEntry *entry;
            if (storageType == 15 || storageType == 14)
            {
                PDDirectoryHeader *dirHead =
                    [[[PDDirectoryHeader alloc] initWithVolume:aVolume
                                               parentDirectory:aDirectory
                                                   parentEntry:directory.fileEntry
                                                         bytes:ptr
                                                        length:0] autorelease];
                entriesPerBlock = dirHead.entriesPerBlock;
                entryLength = dirHead.entryLength;
                entry = dirHead;
            }
            else
                entry = [[[PDFileEntry alloc] initWithVolume:aVolume
                                             parentDirectory:aDirectory
                                                 parentEntry:directory.fileEntry
                                                       bytes:ptr
                                                      length:entryLength] autorelease];
            [entries addObject:entry];

            NSLog(@"Entry - storageType: %d, fileName: %@",
                  entry.storageType,
                  entry.fileName);
            ptr += entryLength;
        }
        while (++i < entriesPerBlock);

        NSLog(@"Block - prev: %d, next: %d",
              self.previousBlockNumber,
              self.nextBlockNumber);
    }
    return self;
}

- (id)initWithVolume:(PDVolume *)aVolume
           directory:(PDDirectory *)aDirectory
         blockNumber:(NSUInteger)aBlockNumber
     entriesPerBlock:(NSUInteger)count
         entryLength:(NSUInteger)length
{
    entriesPerBlock = count;
    entryLength = length;
    return [self initWithVolume:aVolume
                      directory:aDirectory
                    blockNumber:aBlockNumber];
}

- (id)initWithVolume:(PDVolume *)aVolume
           directory:(PDDirectory *)aDirectory
         blockNumber:(NSUInteger)aBlockNumber
     nextBlockNumber:(NSUInteger)aNextBlockNumber
 previousBlockNumber:(NSUInteger)aPreviousBlockNumber
       directoryName:(NSString *)directoryName
       parentPointer:(NSUInteger)parentPointer
   parentEntryNumber:(NSUInteger)parentEntryNumber
   parentEntryLength:(NSUInteger)parentEntryLength
{
    // This is a new directory block, so use the defaults
    entriesPerBlock = 13;
    entryLength = 39;

    blockData = [aVolume.blockStorage mutableDataForBlock:aBlockNumber];
    
    // Set up the next and previous block pointers
    self.nextBlockNumber = aNextBlockNumber;
    self.previousBlockNumber = aPreviousBlockNumber;
    
    // If we've been provided with a directory name, we'll use that to set up a
    // directory header.  If there is no name, we'll consider 
    if (directoryName)
    {
        PDDirectoryHeader *dirHead = [[PDDirectoryHeader alloc] initWithVolume:aVolume
                                                               parentDirectory:aDirectory
                                                                   parentEntry:aDirectory.fileEntry
                                                                         bytes:blockData.mutableBytes + 4
                                                                        length:0];
        dirHead.storageType = 14;
        dirHead.fileName = directoryName;
        dirHead.creationDateAndTime = [NSCalendarDate calendarDate];
        dirHead.version = 0;
        dirHead.minVersion = 0;
        dirHead.access = 0xe3;
        dirHead.entryLength = 0x27;
        dirHead.entriesPerBlock = 0x0d;
        dirHead.fileCount = 0;
        dirHead.parentPointer = parentPointer;
        dirHead.parentEntryNumber = parentEntryNumber;
        dirHead.parentEntryLength = parentEntryLength;
        
        // Release this header object, as everything is stored in the backing
        // block data, and it will be recreated in the following init.
        [dirHead release];
    }
    [aVolume.blockStorage markModifiedBlockAtIndex:aBlockNumber];
    
    return [self initWithVolume:aVolume
                      directory:aDirectory
                    blockNumber:aBlockNumber];
}

- (void)dealloc
{
    [entries release];
    [blockData release];
    [super dealloc];
}

- (NSUInteger)previousBlockNumber
{
    unsigned char *ptr = blockData.mutableBytes;
    return unpackWord(ptr);
}

- (void)setPreviousBlockNumber:(NSUInteger)aBlockNumber
{
    unsigned char *ptr = blockData.mutableBytes;
    packWord(ptr, aBlockNumber);
}

- (NSUInteger)nextBlockNumber
{
    unsigned char *ptr = blockData.mutableBytes;
    return unpackWord(ptr + 2);
}

- (void)setNextBlockNumber:(NSUInteger)aBlockNumber
{
    unsigned char *ptr = blockData.mutableBytes;
    packWord(ptr + 2, aBlockNumber);
}

//@synthesize directory;

@synthesize blockNumber;

@synthesize entriesPerBlock;

@synthesize entryLength;

@synthesize entries;

- (NSData *)data
{
    return blockData;
}

- (NSInteger)findInactiveEntryIndex
{
    // Find the first inactive entry
    NSInteger count = 0;
    for (PDEntry *entry in entries)
        if (entry.storageType == 0)
            return count;
        else
            ++count;
    return -1;
}

@end
