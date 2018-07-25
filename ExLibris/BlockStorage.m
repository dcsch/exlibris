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

@interface BlockStorage ()
{
    MediaDevice *_device;
    int _fd;
    NSMutableDictionary *_blocks;
    NSMutableSet *_modifiedIndicies;
    BOOL _newStorage;
}

@end


@implementation BlockStorage

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        // The cache of read and modified blocks
        _blocks = [[NSMutableDictionary alloc] init];
        _modifiedIndicies = [[NSMutableSet alloc] init];
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)absoluteURL
{
    self = [self init];
    if (self)
    {
        _path = [absoluteURL.path copy];
        _blockSize = kProDOSBlockSize;

        if ([_path hasPrefix:@"/dev/"])
        {
            // This is a ProDOS device

            // Chop up the path into device and partition
            NSString *partitionString = _path.lastPathComponent;
            NSInteger partition = partitionString.integerValue;
            NSString *devicePath = _path.stringByDeletingLastPathComponent;
            
            _path = devicePath;
            
            // We've been passed a device name, so find it in our
            // collection of devices
            NSArray *deviceArray = [MediaDevice devices];
            for (MediaDevice *md in deviceArray)
                if ([md.path isEqualToString:_path])
                {
                    _device = md;
                    _length = _device.size;
                    break;
                }
            
            if (!_device)
            {
                self = nil;
            }
            
            _partitionOffset = kMaxProDOSVolumeSize * partition;
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

- (instancetype)initWithBlockSize:(NSUInteger)aBlockSize capacity:(NSUInteger)blockCount
{
    self = [self init];
    if (self)
    {
        _blockSize = aBlockSize;
        
        // Create a cache where every block is modified
        NSUInteger blockIndex;
        for (blockIndex = 0; blockIndex < blockCount; ++blockIndex)
        {
            [self zeroBlock:blockIndex];
            [self markModifiedBlockAtIndex:blockIndex];
        }
        _length = _blockSize * blockCount;
        
        // We flag this as new storage so that when a path is assigned,
        // any existing file with that path are deleted
        _newStorage = YES;
    }
    return self;
}

//- (id)initWithURL:(NSURL *)absoluteURL blockStorage:(BlockStorage *)aBlockStorage
//{
//}

- (void)dealloc
{
    [self close];
}

- (void)setBlockSize:(NSUInteger)aBlockSize
{
    // The block can't exceed the ProDOS block size.  This facility exists
    // so that DOS 3.3 sectors can be handled as 'blocks'.
    if (aBlockSize <= kProDOSBlockSize)
        _blockSize = aBlockSize;
}

- (void)setDosToProdosSectorMapping:(BOOL)sectorMapping
{
    if (_dosToProdosSectorMapping != sectorMapping)
    {
        // The mapping is changing, so we need to flush the block cache
        [_blocks removeAllObjects];
        _dosToProdosSectorMapping = sectorMapping;
    }
}

- (void)open
{
    if (_fd <= 0 && _path != nil)
        _fd = open(_path.UTF8String, O_RDONLY);
}

- (void)openForWriting
{
    int oflag = O_WRONLY | O_CREAT;
    if (_newStorage)
    {
        // Since this is a new storage, we must be sure to clear any existing
        // file with the same path name
        oflag |= O_TRUNC;
        _newStorage = NO;
    }

    if (_fd <= 0 && _path != nil)
        _fd = open(_path.UTF8String,
                   oflag,
                   S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH | S_IWOTH);
}

- (void)close
{
    if (_fd > 0)
    {
        close(_fd);
        _fd = 0;
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
    NSMutableData *blockData = _blocks[@(blockIndex)];
    if (blockData)
        return blockData;

    if (_fd <= 0)
        [self open];
    
    if (_fd > 0)
    {
        unsigned char buf[kProDOSBlockSize];

        if (_dosToProdosSectorMapping)
        {
            const NSUInteger sectorSize = 256;

            // Translate block number to DOS-ordered sector numbers
            NSUInteger track = (2 * blockIndex) / 16;
            
            unsigned int sector1 = (2 * blockIndex) % 16;
            if (sector1 > 0)
                sector1 = 15 - sector1;
            sector1 += 16 * track;
            
            unsigned int sector2 = (2 * blockIndex + 1) % 16;
            if (sector2 < 15)
                sector2 = 15 - sector2;
            sector2 += 16 * track;
            
            off_t pos = sectorSize * sector1 + _partitionOffset;
            lseek(_fd, pos, SEEK_SET);
            ssize_t bytesRead = read(_fd, buf, sectorSize);
            
            NSLog(@"Read block %lu (sector %d) (%ld bytes @ %lld)", (unsigned long)blockIndex, sector1, bytesRead, pos);
            
            pos = sectorSize * sector2 + _partitionOffset;
            lseek(_fd, pos, SEEK_SET);
            bytesRead = read(_fd, buf + sectorSize, sectorSize);
            
            NSLog(@"Read block %lu (sector %d) (%ld bytes @ %lld)", (unsigned long)blockIndex, sector2, bytesRead, pos);
        }
        else
        {
            off_t pos = _blockSize * blockIndex + _partitionOffset;
            lseek(_fd, pos, SEEK_SET);
            ssize_t bytesRead = read(_fd, buf, _blockSize);
            
            NSLog(@"Read block %lu (%ld bytes @ %lld)", (unsigned long)blockIndex, bytesRead, pos);
        }

        blockData = [NSMutableData dataWithBytes:buf length:_blockSize];
        _blocks[@(blockIndex)] = blockData;
    }

    return blockData;
}

- (void)precacheBlocksInRange:(NSRange)range
{
    for (NSUInteger i = range.location; i < range.location + range.length; ++i)
        [self mutableDataForBlock:i];
}

- (NSData *)headerDataWithLength:(NSUInteger)dataLength
{
    if (_fd <= 0)
        [self open];
    if (_fd > 0)
    {
        NSMutableData *data = [NSMutableData dataWithLength:dataLength];
        pread(_fd, data.mutableBytes, dataLength, 0);
        return data;
    }
    return nil;
}

- (void)zeroBlock:(NSUInteger)blockIndex
{
    // Create a block full of zeros, and put it into the cache
    NSMutableData *blockData = [NSMutableData dataWithLength:kProDOSBlockSize];
    _blocks[@(blockIndex)] = blockData;
}

- (void)markModifiedBlockAtIndex:(NSUInteger)blockIndex
{
    [_modifiedIndicies addObject:@(blockIndex)];
}

- (void)markModifiedBlocksInRange:(NSRange)range
{
    for (NSUInteger i = range.location; i < range.location + range.length; ++i)
        [_modifiedIndicies addObject:@(i)];
}

- (BOOL)commitModifiedBlocks
{
    // Reopen the file for writing
    [self close];
    [self openForWriting];
    
    if (_headerData)
    {
        pwrite(_fd, _headerData.bytes, _headerData.length, 0);
        _partitionOffset = _headerData.length;
    }

    // Iterate through the modified blocks, writing each one out
    for (NSNumber *blockNumber in _modifiedIndicies)
    {
        NSData *block = _blocks[blockNumber];
        NSUInteger blockIndex = blockNumber.unsignedIntegerValue;
        off_t pos = _blockSize * blockIndex + _partitionOffset;
        ssize_t bytesWritten = pwrite(_fd, block.bytes, _blockSize, pos);
        
        NSLog(@"Write block %lu (%ld bytes @ %lld)", (unsigned long)blockIndex, bytesWritten, pos);
    }

    [self close];
    [_modifiedIndicies removeAllObjects];
    
    return YES;
}

@end
