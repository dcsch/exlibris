//
//  BlockStorage.m
//  Disk II
//
//  Created by David Schweinsberg on 19/08/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import "BlockStorage.h"
#import "MediaDevice.h"
#import "DiskII.h"
#include <util.h>

@implementation BlockStorage

- (id)init
{
    self = [super init];
    if (self)
    {
        // The cache of read and modified blocks
        blocks = [[NSMutableDictionary alloc] init];
        modifiedIndicies = [[NSMutableSet alloc] init];
    }
    return self;
}

- (id)initWithURL:(NSURL *)absoluteURL
{
    self = [self init];
    if (self)
    {
        path = [absoluteURL.path copy];
        blockSize = kProDOSBlockSize;

        if ([path hasPrefix:@"/dev/"])
        {
            // This is a ProDOS device

            // Chop up the path into device and partition
            NSString *partitionString = path.lastPathComponent;
            NSInteger partition = partitionString.integerValue;
            NSString *devicePath = path.stringByDeletingLastPathComponent;
            
            [path release];
            path = devicePath;
            [path retain];
            
            // We've been passed a device name, so find it in our
            // collection of devices
            NSArray *deviceArray = [MediaDevice devices];
            for (MediaDevice *md in deviceArray)
                if ([md.path isEqualToString:path])
                {
                    device = md;
                    length = device.size;
                    break;
                }
            
            if (!device)
            {
                [self release];
                self = nil;
            }
            
            partitionOffset = kMaxProDOSVolumeSize * partition;
        }
        else
        {
            // This is a file in a file system

//            // Read the header in if we're told to expect one
//            if (aHeader)
//            {
//                // This is a bit hacky but it will do for the moment
//                const size_t bufSize = 64;
//                unsigned char buf[bufSize];
//                [self open];
//                ssize_t bytesRead = read(fd, buf, bufSize);
//                if (bytesRead)
//                {
//                    NSData *data = [NSData dataWithBytes:buf length:bufSize];
//                    header = [[DiskImageHeader alloc] initWithData:data];
//                    if (header)
//                    {
//                        //sectorOrdering = [header imageFormat];
//                        partitionOffset = [header imageDataOffset];
//                    }
//                }
//            }
        }
    }
    return self;
}

- (id)initWithBlockSize:(NSUInteger)aBlockSize capacity:(NSUInteger)blockCount
{
    self = [self init];
    if (self)
    {
        blockSize = aBlockSize;
        
        // Create a cache where every block is modified
        NSUInteger blockIndex;
        for (blockIndex = 0; blockIndex < blockCount; ++blockIndex)
        {
            [self zeroBlock:blockIndex];
            [self markModifiedBlockAtIndex:blockIndex];
        }
        length = blockSize * blockCount;
        
        // We flag this as new storage so that when a path is assigned,
        // any existing file with that path are deleted
        newStorage = YES;
    }
    return self;
}

//- (id)initWithURL:(NSURL *)absoluteURL blockStorage:(BlockStorage *)aBlockStorage
//{
//}

- (void)dealloc
{
    [self close];
    [path release];
    [blocks release];
    [modifiedIndicies release];
    [headerData release];
    [super dealloc];
}

- (NSString *)path
{
    return path;
}

- (void)setPath:(NSString *)aPath
{
    [path release];
    path = [aPath copy];
}

- (NSUInteger)blockSize
{
    return blockSize;
}

- (void)setBlockSize:(NSUInteger)aBlockSize
{
    // The block can't exceed the ProDOS block size.  This facility exists
    // so that DOS 3.3 sectors can be handled as 'blocks'.
    if (aBlockSize <= kProDOSBlockSize)
        blockSize = aBlockSize;
}

- (BOOL)dosToProdosSectorMapping
{
    return dosToProdosSectorMapping;
}

- (void)setDosToProdosSectorMapping:(BOOL)sectorMapping
{
    if (dosToProdosSectorMapping != sectorMapping)
    {
        // The mapping is changing, so we need to flush the block cache
        [blocks removeAllObjects];
        dosToProdosSectorMapping = sectorMapping;
    }
}

- (void)open
{
    if (fd <= 0 && path != nil)
        fd = open(path.UTF8String, O_RDONLY);
}

- (void)openForWriting
{
    int oflag = O_WRONLY | O_CREAT;
    if (newStorage)
    {
        // Since this is a new storage, we must be sure to clear any existing
        // file with the same path name
        oflag |= O_TRUNC;
        newStorage = NO;
    }

    if (fd <= 0 && path != nil)
        fd = open(path.UTF8String,
                  oflag,
                  S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH | S_IWOTH);
}

- (void)close
{
    if (fd > 0)
    {
        close(fd);
        fd = 0;
    }
}

//- (NSData *)dataForBlock:(NSUInteger)blockIndex

- (void)setData:(NSData *)data forBlock:(NSUInteger)blockIndex
{
    NSMutableData *blockData = [self mutableDataForBlock:blockIndex];
    [blockData setData:data];
    [self markModifiedBlockAtIndex:blockIndex];
}

- (NSMutableData *)mutableDataForBlock:(NSUInteger)blockIndex
{
    // Is it cached?
    NSMutableData *blockData =
        [blocks objectForKey:[NSNumber numberWithUnsignedInteger:blockIndex]];
    if (blockData)
        return blockData;

    if (fd <= 0)
        [self open];
    
    if (fd > 0)
    {
        unsigned char buf[kProDOSBlockSize];

        if (dosToProdosSectorMapping)
        {
            const NSUInteger sectorSize = 256;

            // Translate block number to DOS-ordered sector numbers
            unsigned int track = (2 * blockIndex) / 16;
            
            unsigned int sector1 = (2 * blockIndex) % 16;
            if (sector1 > 0)
                sector1 = 15 - sector1;
            sector1 += 16 * track;
            
            unsigned int sector2 = (2 * blockIndex + 1) % 16;
            if (sector2 < 15)
                sector2 = 15 - sector2;
            sector2 += 16 * track;
            
            off_t pos = sectorSize * sector1 + partitionOffset;
            lseek(fd, pos, SEEK_SET);
            ssize_t bytesRead = read(fd, buf, sectorSize);
            
            NSLog(@"Read block %d (sector %d) (%d bytes @ %d)", blockIndex, sector1, bytesRead, pos);
            
            pos = sectorSize * sector2 + partitionOffset;
            lseek(fd, pos, SEEK_SET);
            bytesRead = read(fd, buf + sectorSize, sectorSize);
            
            NSLog(@"Read block %d (sector %d) (%d bytes @ %d)", blockIndex, sector2, bytesRead, pos);
        }
        else
        {
            off_t pos = blockSize * blockIndex + partitionOffset;
            lseek(fd, pos, SEEK_SET);
            ssize_t bytesRead = read(fd, buf, blockSize);
            
            NSLog(@"Read block %d (%d bytes @ %d)", blockIndex, bytesRead, pos);
        }

        blockData = [NSMutableData dataWithBytes:buf length:blockSize];
        [blocks setObject:blockData forKey:[NSNumber numberWithUnsignedInteger:blockIndex]];
    }

    return blockData;
}

- (NSData *)headerDataWithLength:(NSUInteger)dataLength
{
    if (fd <= 0)
        [self open];
    if (fd > 0)
    {
        NSMutableData *data = [NSMutableData dataWithLength:dataLength];
        pread(fd, data.mutableBytes, dataLength, 0);
        return data;
    }
    return nil;
}

- (void)zeroBlock:(NSUInteger)blockIndex
{
    // Create a block full of zeros, and put it into the cache
    NSMutableData *blockData = [NSMutableData dataWithLength:kProDOSBlockSize];
    [blocks setObject:blockData forKey:[NSNumber numberWithUnsignedInteger:blockIndex]];
}

- (void)markModifiedBlockAtIndex:(NSUInteger)blockIndex
{
    [modifiedIndicies addObject:[NSNumber numberWithUnsignedInt:blockIndex]];
}

- (BOOL)commitModifiedBlocks
{
    // Reopen the file for writing
    [self close];
    [self openForWriting];
    
    if (headerData)
    {
        pwrite(fd, headerData.bytes, headerData.length, 0);
        partitionOffset = headerData.length;
    }

    // Iterate through the modified blocks, writing each one out
    for (NSNumber *blockNumber in modifiedIndicies)
    {
        NSData *block = [blocks objectForKey:blockNumber];
        NSUInteger blockIndex = blockNumber.unsignedIntegerValue;
        off_t pos = blockSize * blockIndex + partitionOffset;
        ssize_t bytesWritten = pwrite(fd, block.bytes, blockSize, pos);
        
        NSLog(@"Write block %d (%d bytes @ %d)", blockIndex, bytesWritten, pos);
    }

    [self close];
    [modifiedIndicies removeAllObjects];
    
    return YES;
}

@synthesize length;

@synthesize partitionOffset;

@synthesize headerData;

@end
