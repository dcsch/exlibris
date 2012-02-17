//
//  PDDirectory.m
//  Disk II
//
//  Created by David Schweinsberg on 2/01/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import "PDDirectory.h"
#import "PDVolume.h"
#import "PDDirectoryBlock.h"
#import "PDDirectoryHeader.h"
#import "PDFileEntry.h"
#import "PDFileType.h"
#import "BlockStorage.h"
#import "DiskII.h"
#import "Error.h"

@interface PDDirectory (Private)

+ (NSUInteger)blockCountForData:(NSData *)aData;

+ (NSUInteger)requiredStorageTypeForData:(NSData *)aData;

+ (NSUInteger)requiredStorageBlockCountForData:(NSData *)aData;

+ (void)addBlockNumber:(NSNumber *)aBlockNumber
          toIndexBlock:(NSMutableData *)aBlock
              atOffset:(NSUInteger)aIndexOffset;

+ (NSDictionary *)createBlocks:(NSArray *)aBlockNumbers forData:(NSData *)aData;

- (void)collectEntries;

@end

@implementation PDDirectory

- (id)initWithVolume:(PDVolume *)aVolume
         blockNumber:(unsigned int)aBlockNumber
{
    self = [super init];
    if (self)
    {
        volume = aVolume;

        blocks = [[NSMutableArray alloc] init];
        entries = [[NSMutableArray alloc] init];
        
        // Load all the directory blocks for this directory
        PDDirectoryBlock *keyBlock = nil;
        NSUInteger blockNumber = aBlockNumber;
        while (blockNumber)
        {
            PDDirectoryBlock *block;
            if (keyBlock)
                block = [[[PDDirectoryBlock alloc] initWithVolume:volume
                                                        directory:self
                                                      blockNumber:blockNumber
                                                  entriesPerBlock:[keyBlock entriesPerBlock]
                                                      entryLength:[keyBlock entryLength]] autorelease];
            else
            {
                block = [[[PDDirectoryBlock alloc] initWithVolume:volume
                                                        directory:self
                                                      blockNumber:blockNumber] autorelease];
                keyBlock = block;
            }

            if (block == nil)
            {
                // Not a valid directory block (not a ProDOS volume?)
                [self release];
                return nil;
            }
            [blocks addObject:block];
            blockNumber = [block nextBlockNumber];
        }

        [self collectEntries];
    }
    return self;
}

- (id)initWithFileEntry:(PDFileEntry *)aFileEntry
{
    fileEntry = aFileEntry;
    return [self initWithVolume:fileEntry.volume
                    blockNumber:fileEntry.keyPointer];
}

- (void)dealloc
{
    [entries release];
    [blocks release];
    [super dealloc];
}

- (NSString *)name
{
    PDDirectoryBlock *block = [blocks objectAtIndex:0];
    if (block)
    {
        PDDirectoryHeader *dirHead = [block.entries objectAtIndex:0];
        if (dirHead)
            return dirHead.fileName;
    }
    return nil;
}

- (void)setName:(NSString *)aName
{
    PDDirectoryBlock *block = [blocks objectAtIndex:0];
    if (block)
    {
        PDDirectoryHeader *dirHead = [block.entries objectAtIndex:0];
        if (dirHead)
            dirHead.fileName = aName;
    }
}

- (BOOL)allEntriesVisible
{
    return allEntriesVisible;
}

- (void)setAllEntriesVisible:(BOOL)flag
{
    if (allEntriesVisible != flag)
    {
        allEntriesVisible = flag;
        [self collectEntries];
    }
}

+ (NSUInteger)blockCountForData:(NSData *)aData
{
    NSUInteger blocksNeeded = aData.length / kProDOSBlockSize;
    if (aData.length % kProDOSBlockSize)
        ++blocksNeeded;
    return blocksNeeded;
}

+ (NSUInteger)requiredStorageTypeForData:(NSData *)aData
{
    NSUInteger blocksNeeded = [PDDirectory blockCountForData:aData];
    if (blocksNeeded == 1)
        return SEEDLING_FILE;
    else if (blocksNeeded <= 256)
        return SAPLING_FILE;
    else
        return TREE_FILE;
}

+ (NSUInteger)requiredStorageBlockCountForData:(NSData *)aData
{
    NSUInteger blocksNeeded = [PDDirectory blockCountForData:aData];
    NSUInteger storageType = [PDDirectory requiredStorageTypeForData:aData];
    switch (storageType)
    {
        case SEEDLING_FILE:
            // Seedling file -- no index blocks
            break;
            
        case SAPLING_FILE:
            // Sapling file -- one index block
            ++blocksNeeded;
            break;
            
        case TREE_FILE:
            // Tree file
            blocksNeeded += blocksNeeded % 256;  // subindex blocks
            ++blocksNeeded;                      // Master index block
            break;
    }
    return blocksNeeded;
}

+ (void)addBlockNumber:(NSNumber *)aBlockNumber
          toIndexBlock:(NSMutableData *)aBlock
              atOffset:(NSUInteger)aIndexOffset
{
    unsigned char *ptr = aBlock.mutableBytes;
    ptr[aIndexOffset] = (unsigned char) aBlockNumber.unsignedIntValue;
    ptr[256 + aIndexOffset] = (unsigned char)(aBlockNumber.unsignedIntValue >> 8);
}

+ (NSDictionary *)createBlocks:(NSArray *)aBlockNumbers forData:(NSData *)aData
{
    NSMutableDictionary *dict =
        [NSMutableDictionary dictionaryWithCapacity:aBlockNumbers.count];
    //NSUInteger storageType = [PDDirectory requiredStorageTypeForData:aData];
    
    // Break data into blocks, interleaving any required index blocks
    NSMutableData *currentIndexBlock = nil;
    NSMutableData *masterIndexBlock = nil;
    NSUInteger currentIndexOffset = 0;
    NSUInteger masterIndexOffset = 0;
    NSUInteger dataBlockCount = 0;
    NSNumber *currentBlockNumber = nil;
    NSNumber *currentIndexBlockNumber = nil;
    for (NSNumber *blockNumber in aBlockNumbers)
    {
        // Do we need to create an index block here?
        if (dataBlockCount == 1 && currentIndexBlock == nil)
        {
            // Create the first index block
            currentIndexBlockNumber = blockNumber;
            currentIndexBlock = [NSMutableData dataWithLength:kProDOSBlockSize];
            [dict setObject:currentIndexBlock forKey:blockNumber];

            // Add the first data block to it
            [PDDirectory addBlockNumber:currentBlockNumber
                           toIndexBlock:currentIndexBlock
                               atOffset:currentIndexOffset];
            ++currentIndexOffset;
            
            continue;
        }

        if (dataBlockCount > 1 && dataBlockCount % 256 == 0)
        {
            if (masterIndexBlock == nil)
            {
                // Create the first master index block
                masterIndexBlock = [NSMutableData dataWithLength:kProDOSBlockSize];
                [dict setObject:masterIndexBlock forKey:blockNumber];
                
                // Add the first index block to it
                [PDDirectory addBlockNumber:currentIndexBlockNumber
                               toIndexBlock:masterIndexBlock
                                   atOffset:masterIndexOffset];
                ++masterIndexOffset;
                
                // The next required index block will be created on the next iteration
                continue;
            }

            // Create another index block
            currentIndexBlockNumber = blockNumber;
            currentIndexBlock = [NSMutableData dataWithLength:kProDOSBlockSize];
            currentIndexOffset = 0;
            [dict setObject:currentIndexBlock forKey:blockNumber];
            
            // Add this to the master index block
            [PDDirectory addBlockNumber:currentIndexBlockNumber
                           toIndexBlock:masterIndexBlock
                               atOffset:masterIndexOffset];
            ++masterIndexOffset;
            
            continue;
        }

        // Add the data block
        currentBlockNumber = blockNumber;
        NSRange range = NSMakeRange(kProDOSBlockSize * dataBlockCount, kProDOSBlockSize);
        [dict setObject:[aData subdataWithRange:range] forKey:blockNumber];
        ++dataBlockCount;

        // Add the index reference
        if (currentIndexBlock)
        {
            [PDDirectory addBlockNumber:blockNumber
                           toIndexBlock:currentIndexBlock
                               atOffset:currentIndexOffset];
            ++currentIndexOffset;
        }
    }
    return dict;
}

- (BOOL)createFileWithEntry:(PDFileEntry *)aFileEntry
                       data:(NSData *)aData
{
    NSLog(@"Creating file: %@ in directory: %@", aFileEntry.fileName, self.name);
    
    // Do we have space in the existing directory blocks, or do we need to add one?
    BOOL directorySpace = NO;
    for (PDDirectoryBlock *block in blocks)
    {
//        if (block.entries.count < block.entriesPerBlock)
//        {
//            directorySpace = YES;
//            break;
//        }
        
        for (PDEntry *entry in [block entries])
        {
            if ([entry storageType] == 0)
            {
                directorySpace = YES;
                break;
            }
        }
        
        if (directorySpace)
            break;
    }
    
    if (!directorySpace)
    {
        // Add a new directory block
        // NOTE that this can only go ahead if this isn't the volume directory
        PDDirectoryBlock *lastDirBlock = [blocks objectAtIndex:blocks.count - 1];
        NSUInteger dirBlockNumber = [[[volume allocateBlocks:1] objectAtIndex:0] unsignedIntegerValue];
        
        // Clear out any old data in the block
        [volume.blockStorage zeroBlock:dirBlockNumber];
        
        // Create a new directory block and add it into the linked list
        PDDirectoryBlock *dirBlock =
        [[PDDirectoryBlock alloc] initWithVolume:volume
                                       directory:self
                                     blockNumber:dirBlockNumber
                                 entriesPerBlock:lastDirBlock.entriesPerBlock
                                     entryLength:lastDirBlock.entryLength];
        lastDirBlock.nextBlockNumber = dirBlockNumber;
        dirBlock.previousBlockNumber = lastDirBlock.blockNumber;
    }
    
    // Determine the number of blocks required, and confirm that this matches
    // with the file entry.
    NSUInteger blocksNeeded = [PDDirectory requiredStorageBlockCountForData:aData];
    if (blocksNeeded != aFileEntry.blocksUsed)
    {
        NSLog(@"WARNING: There is disagreement about the number of blocks to be used.  "
              "The file could be sparse, which is unsupported in this release.");
        return NO;
    }
    
    // Allocate block numbers
    NSArray *blockIndicies = [volume allocateBlocks:blocksNeeded];
    NSLog(@"blockIndicies: %@", blockIndicies);
    
    NSDictionary *fileInBlocks =
        [PDDirectory createBlocks:blockIndicies forData:aData];
    
    return YES;
}

- (NSString *)uniqueNameFromString:(NSString *)string
{
    // Check if this name already exists in the active entries
    NSString *currentString = string;
    BOOL duplicate;
    int count = 0;
    do
    {
        duplicate = NO;
        for (PDDirectoryBlock *block in blocks)
        {
            for (PDEntry *entry in block.entries)
            {
                if ([entry.fileName isEqualToString:currentString])
                {
                    duplicate = YES;
                    break;
                }
            }

            if (duplicate)
            {
                // Form a new name and try again
                ++count;
                currentString = [NSString stringWithFormat:@"%@.%d", string, count];
                break;
            }
        }
    } while (duplicate);

    return currentString;
}

- (BOOL)createDirectoryWithName:(NSString *)name error:(NSError **)outError
{
    NSArray *allocatedBlocks = nil;
    PDFileEntry *dirEntry = nil;

    // Find a directory block with space for an entry
    NSUInteger absoluteEntryIndex = 0;
    NSUInteger parentDirBlockNumber;
    NSInteger index = -1;
    PDDirectoryBlock *keyDirectoryBlock = nil;
    PDDirectoryBlock *lastDirectoryBlock = nil;
    for (PDDirectoryBlock *block in blocks)
    {
        lastDirectoryBlock = block;
        if (keyDirectoryBlock == nil)
            keyDirectoryBlock = block;

        index = [block findInactiveEntryIndex];
        if (index > -1)
        {
            dirEntry = [block.entries objectAtIndex:index];
            absoluteEntryIndex += index;
            parentDirBlockNumber = block.blockNumber;
            break;
        }
        absoluteEntryIndex += block.entriesPerBlock;
    }
    
    // If the directory header is not visible, then we need to
    // step back one place
    if (!self.allEntriesVisible)
        --absoluteEntryIndex;
    
    if (!dirEntry)
    {
        // If this is the volume directory, then we can't expand it
        if (fileEntry == nil)
        {
            NSLog(@"Volume directory has reached its maximum number of entries.");
            *outError = [Error errorWithCode:ELVolumeDirectoryEntryLimitError];
            return NO;
        }

        // We need to create a new directory block to put our entry in, as well
        // as a new directory block to hold the new directory's entries
        // (We allocate all the blocks at the same time, so we don't end up in
        // the situation that we can successfully allocate half what we need,
        // but fail before the end and have dangling allocations)
        allocatedBlocks = [volume allocateBlocks:2];
        if (allocatedBlocks == nil)
        {
            NSLog(@"There is not enough space on the volume.");
            *outError = [Error errorWithCode:ELVolumeSpaceLimitError];
            return NO;
        }

        NSUInteger dirBlockNumber = [[allocatedBlocks objectAtIndex:0] unsignedIntegerValue];
        [volume.blockStorage zeroBlock:dirBlockNumber];
        PDDirectoryBlock *dirBlock =
        [[PDDirectoryBlock alloc] initWithVolume:volume
                                       directory:self
                                     blockNumber:dirBlockNumber
                                 nextBlockNumber:0
                             previousBlockNumber:lastDirectoryBlock.blockNumber
                                   directoryName:nil
                                   parentPointer:0
                               parentEntryNumber:0
                               parentEntryLength:0];
        lastDirectoryBlock.nextBlockNumber = dirBlockNumber;
        parentDirBlockNumber = lastDirectoryBlock.blockNumber;
        
        [blocks addObject:dirBlock];
        dirEntry = [dirBlock.entries objectAtIndex:0];

        fileEntry.eof += kProDOSBlockSize;

        if (self.allEntriesVisible)
        {
            // Update the entries array
            NSMutableArray *entriesProxy = [self mutableArrayValueForKey:@"entries"];
            for (PDEntry *entry in dirBlock.entries)
                [entriesProxy addObject:entry];
        }
        [dirBlock release];
    }
    else
    {
        // Create a directory block to hold the new directory's entries
        allocatedBlocks = [volume allocateBlocks:1];
        if (allocatedBlocks == nil)
        {
            NSLog(@"There is not enough space on the volume.");
            *outError = [Error errorWithCode:ELVolumeSpaceLimitError];
            return NO;
        }
    }
    
    NSUInteger dirBlockNumber =
        [[allocatedBlocks objectAtIndex:allocatedBlocks.count - 1] unsignedIntegerValue];
    [volume.blockStorage zeroBlock:dirBlockNumber];
    PDDirectoryBlock *dirBlock =
    [[PDDirectoryBlock alloc] initWithVolume:volume
                                   directory:self
                                 blockNumber:dirBlockNumber
                             nextBlockNumber:0
                         previousBlockNumber:0
                               directoryName:name
                               parentPointer:parentDirBlockNumber
                           parentEntryNumber:index + 1
                           parentEntryLength:0x27];

    // Configure this entry as a directory
    [dirEntry clear];
    dirEntry.storageType = 0xd;
    dirEntry.fileName = name;
    dirEntry.fileType = [PDFileType fileTypeWithId:DIRECTORY_FILE_TYPE_ID];
    dirEntry.keyPointer = dirBlockNumber;
    dirEntry.blocksUsed = 1;
    dirEntry.eof = 512;
    dirEntry.creationDateAndTime = [NSCalendarDate calendarDate];
    dirEntry.version = 0;
    dirEntry.minVersion = 0;
    dirEntry.access = 0xe3;
    dirEntry.auxType = 0;
    dirEntry.lastMod = [NSCalendarDate calendarDate];
    dirEntry.headerPointer = keyDirectoryBlock.blockNumber;
    
    // Increment the file count in the directory header
    PDDirectoryHeader *dirHeader = [keyDirectoryBlock.entries objectAtIndex:0];
    dirHeader.fileCount++;
    
    // Inform block storage of the changes we've made
    [volume.blockStorage markModifiedBlockAtIndex:parentDirBlockNumber];
    [volume.blockStorage markModifiedBlockAtIndex:keyDirectoryBlock.blockNumber];
    [volume.blockStorage markModifiedBlockAtIndex:dirHeader.parentPointer];

    // Insert the entry into the entries array
    if (!self.allEntriesVisible)
    {
        NSMutableArray *entriesProxy = [self mutableArrayValueForKey:@"entries"];
        [entriesProxy insertObject:dirEntry atIndex:absoluteEntryIndex];
    }

    // Release these -- they will be rebuilt when the PDDirectory for this
    // new entry is initialized
    [dirBlock release];
    
    NSLog(@"Added new subdirectory (at %d)", absoluteEntryIndex);
    
    return YES;
}

- (void)deleteFileEntry:(PDFileEntry *)aFileEntry
{
//    for (PDDirectoryBlock *block in blocks)
//    {
//        NSUInteger entryIndex = [block indexOfObject:aFileEntry];
//        if (entryIndex != NSNotFound)
//        {
//            aFileEntry.storageType = 0;
//        }
//    }
}

- (id)valueForUndefinedKey:(NSString *)key
{
    return @"BOOP";
}

- (void)collectEntries
{
    // We must use the proxy so that KVO works correctly
    NSMutableArray *entriesProxy = [self mutableArrayValueForKey:@"entries"];
    [entriesProxy removeAllObjects];
    
    BOOL showAll = self.allEntriesVisible;
    for (PDDirectoryBlock *block in blocks)
    {
        for (PDEntry *entry in block.entries)
        {
            if (!showAll && (entry.storageType == 0 || entry.storageType == 15 || entry.storageType == 14))
                continue;
            [entriesProxy addObject:entry];
            
            // Cascade this change to all subdirectories
            if (entry.storageType == 0xd)
                ((PDFileEntry *)entry).directory.allEntriesVisible = showAll;
        }
    }
}

- (NSScriptObjectSpecifier *)objectSpecifier
{
    NSScriptObjectSpecifier *containerSpec = volume.objectSpecifier;
    return [[NSNameSpecifier alloc] initWithContainerClassDescription:containerSpec.keyClassDescription
                                                   containerSpecifier:containerSpec
                                                                  key:@"directory"
                                                                 name:self.name];
}

@synthesize fileEntry;

@synthesize blocks;

@synthesize entries;

@end
