//
//  PDVolume.m
//  Disk II
//
//  Created by David Schweinsberg on 7/02/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import "PDVolume.h"
#import "BlockStorage.h"
#import "PDDirectory.h"
#import "PDFileEntry.h"
#import "PDDirectoryBlock.h"
#import "PDDirectoryHeader.h"
#import "DiskII.h"

static void bitPos(NSUInteger blockNumber,
                   NSUInteger *byteIndex,
                   NSUInteger *bitIndex,
                   NSUInteger *blockIndex)
{
    *byteIndex = blockNumber / 8;
    *bitIndex = 7 - blockNumber % 8;
    *blockIndex = *byteIndex / kProDOSBlockSize;
}

@interface PDVolume (Private)

- (void)appendEntries:(NSArray *)entries toArray:(NSMutableArray *)array;

- (void)appendBlocksFromFileEntry:(PDFileEntry *)fileEntry
                   withIndexBlock:(NSData *)indexData
                    isMasterIndex:(BOOL)masterIndex
                    toMutableData:(NSMutableData *)allBlockData;

- (BOOL)blockAvailableAtIndex:(NSUInteger)blockNumber;

- (void)setBlockAvailable:(BOOL)available atIndex:(NSUInteger)blockNumber;

- (PDDirectoryHeader *)volumeDirectoryHeader;

@end

@implementation PDVolume

+ (void)formatBlockStorage:(BlockStorage *)blockStorage
{
    // A number of things have to be done to format for ProDOS
    // - copy boot code to blocks 0 and 1
    // - create the volume directory in blocks 2 to 5
    // - create the volume bitmap from block 6 for as many blocks as needed
    
    // Get the ProDOS boot data from resources and copy to the first two blocks
    NSBundle *appBundle = [NSBundle mainBundle];
    NSString *path = [appBundle pathForResource:@"prodos.boot" ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSRange blockZero = NSMakeRange(0, kProDOSBlockSize);
    NSRange blockOne = NSMakeRange(kProDOSBlockSize, kProDOSBlockSize);
    [blockStorage setData:[data subdataWithRange:blockZero] forBlock:0];
    [blockStorage setData:[data subdataWithRange:blockOne] forBlock:1];
    
    // Set up the volume directory, first by linking blocks 2 through to 5
    NSMutableData *mutableData = [blockStorage mutableDataForBlock:5];
    unsigned char *bytes = mutableData.mutableBytes;
    bytes[0] = 4;
    bytes[2] = 0;
    mutableData = [blockStorage mutableDataForBlock:4];
    bytes = mutableData.mutableBytes;
    bytes[0] = 3;
    bytes[2] = 5;
    mutableData = [blockStorage mutableDataForBlock:3];
    bytes = mutableData.mutableBytes;
    bytes[0] = 2;
    bytes[2] = 4;
    mutableData = [blockStorage mutableDataForBlock:2];
    bytes = mutableData.mutableBytes;
    bytes[0] = 0;
    bytes[2] = 3;
    
    // Now fill in the data for the directory header
    NSUInteger blockCount = blockStorage.length / blockStorage.blockSize;
    PDDirectoryHeader *dirHead = [[PDDirectoryHeader alloc] initWithVolume:nil
                                                           parentDirectory:nil
                                                               parentEntry:nil
                                                                     bytes:bytes + 4
                                                                    length:0];
    dirHead.storageType = 15;
    dirHead.fileName = @"UNTITLED";
    dirHead.creationDateAndTime = [NSDate date];
    dirHead.version = 0;
    dirHead.minVersion = 0;
    dirHead.access = 0xe3;
    dirHead.entryLength = 0x27;
    dirHead.entriesPerBlock = 0x0d;
    dirHead.fileCount = 0;
    dirHead.bitMapPointer = 6;
    dirHead.totalBlocks = blockCount;
    
    [blockStorage markModifiedBlockAtIndex:2];
    [blockStorage markModifiedBlockAtIndex:3];
    [blockStorage markModifiedBlockAtIndex:4];
    [blockStorage markModifiedBlockAtIndex:5];

    // Create the volume bitmap -- first, how many bitmap blocks do we need?
    NSUInteger bitmapBlockCount = blockCount / (8 * kProDOSBlockSize);
    if (blockCount % (8 * kProDOSBlockSize))
        ++bitmapBlockCount;
    
    // Cache those bitmap blocks
    unsigned char *bitmapBlockBytes[16];
    NSUInteger i;
    for (i = 0; i < bitmapBlockCount; ++i)
    {
        mutableData = [blockStorage mutableDataForBlock:i + 6];
        bitmapBlockBytes[i] = mutableData.mutableBytes;
        [blockStorage markModifiedBlockAtIndex:i + 6];
    }

    // Set all the bits as available
    NSUInteger blockNumber;
    NSUInteger byteIndex;
    NSUInteger bitIndex;
    NSUInteger blockIndex;
    for (blockNumber = 0; blockNumber < blockCount; ++blockNumber)
    {
        bitPos(blockNumber, &byteIndex, &bitIndex, &blockIndex);
        unsigned char *bytes = bitmapBlockBytes[blockIndex];
        unsigned char *byte = bytes + byteIndex - kProDOSBlockSize * blockIndex;
        *byte |= (1 << bitIndex);
    }
    
    // Now set the blocks we've used as unavailable
    NSUInteger usedBlockCount = bitmapBlockCount + 6;
    for (blockNumber = 0; blockNumber < usedBlockCount; ++blockNumber)
    {
        bitPos(blockNumber, &byteIndex, &bitIndex, &blockIndex);
        unsigned char *bytes = bitmapBlockBytes[blockIndex];
        unsigned char *byte = bytes + byteIndex - kProDOSBlockSize * blockIndex;
        *byte &= ~(1 << bitIndex);
    }
}

- (id)initWithContainer:(NSObject *)aContainer
           blockStorage:(BlockStorage *)aBlockStorage
{
    self = [super initWithContainer:aContainer blockStorage:aBlockStorage];
    if (self)
    {
        // Start with the ProDOS Volume Directory block (block number 2)
        directory = [[PDDirectory alloc] initWithVolume:self blockNumber:2];
        
        if (!directory && !blockStorage.dosToProdosSectorMapping)
        {
            // We failed with ProDOS-ordering, so try again with DOS-ordering
            blockStorage.dosToProdosSectorMapping = YES;
            directory = [[PDDirectory alloc] initWithVolume:self blockNumber:2];
        }
        
        if (!directory)
        {
            blockStorage.dosToProdosSectorMapping = NO;
            return nil;
        }

        // Load the volume bitmap
        const NSUInteger kBitsInOneBlock = 8 * kProDOSBlockSize;
        PDDirectoryHeader *dirHead = [self volumeDirectoryHeader];
        volumeBitmapPointer = dirHead.bitMapPointer;
        NSUInteger bitmapBlockCount = dirHead.totalBlocks / kBitsInOneBlock;
        if (dirHead.totalBlocks % kBitsInOneBlock > 0)
            ++bitmapBlockCount;
        volumeBitmapBlocks = [[NSMutableArray alloc] initWithCapacity:bitmapBlockCount];
        NSUInteger i;
        for (i = 0; i < bitmapBlockCount; ++i)
            [volumeBitmapBlocks addObject:[blockStorage mutableDataForBlock:dirHead.bitMapPointer + i]];
        
        NSLog(@"Available blocks: %lu, Total blocks: %lu",
              (unsigned long)self.availableBlockCount,
              (unsigned long)self.totalBlockCount);
        
        // Set up some values from user defaults
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        directory.allEntriesVisible = [defaults boolForKey:ShowAllDirectoryEntriesKey];
    }
    return self;
}


- (PDDirectoryHeader *)volumeDirectoryHeader
{
    PDDirectoryBlock *dirBlock = (directory.blocks)[0];
    return (dirBlock.entries)[0];
}

- (NSString *)name
{
    PDEntry *entry = [self volumeDirectoryHeader];
    return entry.fileName;
}

- (PDDirectory *)directory
{
    return directory;
}

- (void)appendEntries:(NSArray *)entries toArray:(NSMutableArray *)array
{
    for (PDEntry *entry in entries)
    {
        if ([entry isKindOfClass:[PDFileEntry class]])
        {
            PDFileEntry *fileEntry = (PDFileEntry *)entry;
            PDDirectory *dir = fileEntry.directory;
            if (dir)
                [self appendEntries:dir.entries toArray:array];
            else
                [array addObject:fileEntry];
        }
    }
}

- (NSArray *)allEntries
{
    // Walk the entire directory structure and return an array of all file entries
    NSMutableArray *array = [NSMutableArray array];
    [self appendEntries:directory.entries toArray:array];
    return array;
}

- (NSUInteger)availableBlockCount
{
    // How much space is left?  Count all the unallocated blocks.
    NSUInteger totalBlocks = self.totalBlockCount;
    NSUInteger availableBlocks = 0;
    NSUInteger i;
    for (i = 0; i < totalBlocks; ++i)
        if ([self blockAvailableAtIndex:i])
            ++availableBlocks;
    return availableBlocks;
}

- (NSUInteger)totalBlockCount
{
    return self.volumeDirectoryHeader.totalBlocks;
}

- (NSData *)dataForEntry:(PDEntry *)entry includeMetadata:(BOOL)includeMetadata
{
    unsigned int storageType = [entry storageType];
    
    if ([entry isKindOfClass:[PDFileEntry class]])
    {
        PDFileEntry *fileEntry = (PDFileEntry *)entry;
        unsigned int keyPointer = [fileEntry keyPointer];
        unsigned int blockCount = [fileEntry eof] / 512;
        if ([fileEntry eof] % 512 > 0)
            ++blockCount;

        NSUInteger dataSize = 512 * blockCount;
        NSData *metadata = nil;
        if (includeMetadata)
        {
            metadata = entry.entryData;
            dataSize += metadata.length + 1;
        }
        NSMutableData *allBlockData = [NSMutableData dataWithCapacity:dataSize];
        if (metadata)
        {
            // The first byte is a length of the metadata, followed by the
            // metadata itself
            unsigned char metadataLen = (unsigned char)metadata.length;
            [allBlockData appendBytes:&metadataLen length:1];
            [allBlockData appendData:metadata];
        }
        
        // Load according to the storage type
        if (storageType == SEEDLING_FILE)
        {
            NSLog(@"Seedling file");
            
            NSData *data = [blockStorage mutableDataForBlock:keyPointer];
            [allBlockData appendData:data];
            return allBlockData;
        }
        else if (storageType == SAPLING_FILE)
        {
            NSLog(@"Sapling file");
            
            [self appendBlocksFromFileEntry:fileEntry
                             withIndexBlock:[blockStorage mutableDataForBlock:keyPointer]
                              isMasterIndex:NO
                              toMutableData:allBlockData];
            return allBlockData;
        }
        else if (storageType == TREE_FILE)
        {
            NSLog(@"Tree file");
            
            [self appendBlocksFromFileEntry:fileEntry
                             withIndexBlock:[blockStorage mutableDataForBlock:keyPointer]
                              isMasterIndex:YES
                              toMutableData:allBlockData];
            return allBlockData;
        }
        else if (storageType == SUBDIRECTORY)
        {
            NSLog(@"Subdirectory");
            
            PDFileEntry *fileEntry = (PDFileEntry *)entry;
            NSMutableData *mutableData = [NSMutableData dataWithCapacity:512];
            for (PDDirectoryBlock *dirBlock in fileEntry.directory.blocks)
                [mutableData appendData:dirBlock.data];
            return mutableData;
        }
    }
    else if ([entry isKindOfClass:[PDDirectoryHeader class]])
    {
        if (storageType == SUBDIRECTORY_KEY_BLOCK)
        {
            NSLog(@"Subdirectory key block");
            
            return [self dataForEntry:entry.parentEntry
                      includeMetadata:includeMetadata];
        }
        else if (storageType == VOLUME_DIRECTORY_KEY_BLOCK)
        {
            NSLog(@"Volume directory key block");

            // Retrieve the four volume directory blocks
            NSMutableData *mutableData = [NSMutableData dataWithCapacity:2048];
            NSUInteger blockIndex;
            for (blockIndex = 2; blockIndex < 6; ++blockIndex)
                [mutableData appendData:[blockStorage mutableDataForBlock:blockIndex]];
            return mutableData;
        }
    }
    
    NSLog(@"Unhandled storage type: $%x", storageType);
    
    return nil;
}

- (void)appendBlocksFromFileEntry:(PDFileEntry *)fileEntry
                   withIndexBlock:(NSData *)indexData
                    isMasterIndex:(BOOL)masterIndex
                    toMutableData:(NSMutableData *)allBlockData
{
    const unsigned char *ptr = [indexData bytes];
    unsigned int skippedBlocks = 0;
    unsigned int i;
    for (i = 0; i < 256; ++i)
    {
        // The MSB is stored in the second page (half) of the block
        unsigned int blockNumber = ptr[0] | (ptr[256] << 8);
        
        if (masterIndex)
        {
            if (blockNumber)
                [self appendBlocksFromFileEntry:fileEntry
                                 withIndexBlock:[blockStorage mutableDataForBlock:blockNumber]
                                  isMasterIndex:NO
                                  toMutableData:allBlockData];
        }
        else
        {
            // Because this could be a sparse file, be prepared to fill in the
            // gaps of any missing blocks
            if (blockNumber == 0)
                ++skippedBlocks;
            else
            {
                if (skippedBlocks)
                {
                    NSLog(@"Skipped blocks: %d", skippedBlocks);
                    
                    // Fill in the gap with zeroed bytes
                    [allBlockData appendData:[NSMutableData dataWithLength:512 * skippedBlocks]];
                    skippedBlocks = 0;
                }
                [allBlockData appendData:[blockStorage mutableDataForBlock:blockNumber]];
                
                NSLog(@"Block: $%x", blockNumber);
            }
        }
        ptr++;
    }
}

- (BOOL)blockAvailableAtIndex:(NSUInteger)blockNumber
{
    NSUInteger byteIndex = blockNumber / 8;
    NSUInteger bitIndex = 7 - blockNumber % 8;
    NSUInteger blockIndex = byteIndex / kProDOSBlockSize;
    NSData *blockData = volumeBitmapBlocks[blockIndex];
    const unsigned char *bytes = (const unsigned char *)blockData.bytes;
    unsigned char byte = bytes[byteIndex - kProDOSBlockSize * blockIndex];
    return ((byte >> bitIndex) & 1) == 1 ? YES : NO;
}

- (void)setBlockAvailable:(BOOL)available atIndex:(NSUInteger)blockNumber
{
    NSUInteger byteIndex = blockNumber / 8;
    NSUInteger bitIndex = 7 - blockNumber % 8;
    NSUInteger blockIndex = byteIndex / kProDOSBlockSize;
    NSMutableData *blockData = volumeBitmapBlocks[blockIndex];
    unsigned char *bytes = (unsigned char *)blockData.bytes;
    unsigned char *byte = bytes + byteIndex - kProDOSBlockSize * blockIndex;
    if (available)
        *byte |= (1 << bitIndex);
    else
        *byte &= ~(1 << bitIndex);
    
    // We've modified the volume bitmap, so mark the block as modified
    [blockStorage markModifiedBlockAtIndex:volumeBitmapPointer + blockIndex];
}

- (NSArray *)allocateBlocks:(NSUInteger)aBlockCount
{
    // Do we have enough to spare?
    if (aBlockCount > self.availableBlockCount)
        return nil;
    
    NSUInteger total = self.totalBlockCount;
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:aBlockCount];
    NSUInteger i;
    for (i = 0; i < total; ++i)
        if ([self blockAvailableAtIndex:i])
        {
            [self setBlockAvailable:NO atIndex:i];
            [array addObject:@(i)];
            if (array.count == aBlockCount)
                break;
        }

    NSLog(@"Allocated: %@", array);
    
    NSLog(@"Allocated %lu blocks, Available blocks: %lu, Total blocks: %lu",
          (unsigned long)aBlockCount,
          (unsigned long)self.availableBlockCount,
          (unsigned long)self.totalBlockCount);

    return array;
}

@end
