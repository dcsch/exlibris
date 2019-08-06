//
//  PDVolume.h
//  Disk II
//
//  Created by David Schweinsberg on 7/02/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import "Volume.h"
#import <Cocoa/Cocoa.h>

#define SEEDLING_FILE 1
#define SAPLING_FILE 2
#define TREE_FILE 3
#define PASCAL_AREA 4
#define SUBDIRECTORY 0xD
#define SUBDIRECTORY_KEY_BLOCK 0xE
#define VOLUME_DIRECTORY_KEY_BLOCK 0xF

@class PDBlock;
@class PDDirectory;
@class PDEntry;
@class PDFileEntry;
@class PDDirectoryHeader;

@interface PDVolume : Volume {
  PDDirectory *directory;
  NSMutableArray *volumeBitmapBlocks;
  NSUInteger volumeBitmapPointer;
}

@property(strong, readonly) PDDirectory *directory;

@property(strong, readonly) NSArray *allEntries;

@property(readonly) NSUInteger availableBlockCount;

@property(readonly) NSUInteger totalBlockCount;

+ (void)formatBlockStorage:(BlockStorage *)blockStorage;

- (instancetype)initWithContainer:(NSObject *)aContainer
                     blockStorage:(BlockStorage *)aBlockStorage
    NS_DESIGNATED_INITIALIZER;

- (NSData *)dataForEntry:(PDEntry *)entry appendMetadata:(BOOL)appendMetadata;

- (NSArray *)allocateBlocks:(NSUInteger)aBlockCount;

- (void)deallocateBlocks:(NSArray *)blockIndicies;

@end
