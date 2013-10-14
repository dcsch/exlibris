//
//  PDVolume.h
//  Disk II
//
//  Created by David Schweinsberg on 7/02/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Volume.h"

#define SEEDLING_FILE                1
#define SAPLING_FILE                 2
#define TREE_FILE                    3
#define PASCAL_AREA                  4
#define SUBDIRECTORY               0xD
#define SUBDIRECTORY_KEY_BLOCK     0xE
#define VOLUME_DIRECTORY_KEY_BLOCK 0xF

@class PDBlock;
@class PDDirectory;
@class PDEntry;
@class PDFileEntry;
@class PDDirectoryHeader;

@interface PDVolume : Volume
{
    PDDirectory *directory;
    NSMutableArray *volumeBitmapBlocks;
    NSUInteger volumeBitmapPointer;
}

@property(strong, readonly) PDDirectory *directory;

@property(strong, readonly) NSArray *allEntries;

@property(readonly) NSUInteger availableBlockCount;

@property(readonly) NSUInteger totalBlockCount;

+ (void)formatBlockStorage:(BlockStorage *)blockStorage;

- (id)initWithContainer:(NSObject *)aContainer
           blockStorage:(BlockStorage *)aBlockStorage;

- (NSData *)dataForEntry:(PDEntry *)entry includeMetadata:(BOOL)includeMetadata;

- (NSArray *)allocateBlocks:(NSUInteger)aBlockCount;

@end
