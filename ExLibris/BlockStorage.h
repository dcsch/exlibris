//
//  BlockStorage.h
//  Disk II
//
//  Created by David Schweinsberg on 19/08/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MediaDevice;

@interface BlockStorage : NSObject
{
    NSString *path;
    NSUInteger blockSize;
    NSUInteger length;
    NSUInteger partitionOffset;
    MediaDevice *device;
    int fd;
    NSMutableDictionary *blocks;
    NSMutableSet *modifiedIndicies;
    BOOL dosToProdosSectorMapping;
    BOOL newStorage;
    NSData *headerData;
}

@property(copy) NSString *path;

@property NSUInteger blockSize;

@property(readonly) NSUInteger length;

@property NSUInteger partitionOffset;

@property BOOL dosToProdosSectorMapping;

@property(copy) NSData *headerData;

- (id)initWithURL:(NSURL *)absoluteURL;

- (id)initWithBlockSize:(NSUInteger)aBlockSize capacity:(NSUInteger)blockCount;

//- (id)initWithURL:(NSURL *)absoluteURL blockStorage:(BlockStorage *)aBlockStorage;

- (void)open;

- (void)openForWriting;

- (void)close;

//- (NSData *)dataForBlock:(NSUInteger)blockIndex;

- (void)setData:(NSData *)data forBlock:(NSUInteger)blockIndex;

- (NSMutableData *)mutableDataForBlock:(NSUInteger)blockIndex;

- (NSData *)headerDataWithLength:(NSUInteger)dataLength;

- (void)zeroBlock:(NSUInteger)blockIndex;

- (void)markModifiedBlockAtIndex:(NSUInteger)blockIndex;

- (BOOL)commitModifiedBlocks;

@end
