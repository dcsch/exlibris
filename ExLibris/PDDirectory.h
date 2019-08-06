//
//  PDDirectory.h
//  Disk II
//
//  Created by David Schweinsberg on 2/01/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PDVolume;
@class PDEntry;
@class PDFileEntry;

@interface PDDirectory : NSObject

@property(strong, readonly) PDFileEntry *fileEntry;
@property(strong, readonly) NSArray *blocks;
@property(strong, readonly) NSArray *entries;
@property(copy) NSString *name;
@property(nonatomic) BOOL allEntriesVisible;

- (instancetype)initWithVolume:(PDVolume *)aVolume
                   blockNumber:(NSUInteger)aBlockNumber
    NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithFileEntry:(PDFileEntry *)aFileEntry;

- (instancetype)init __attribute__((unavailable));

- (BOOL)createFileWithEntry:(PDFileEntry *)aFileEntry data:(NSData *)aData;

- (PDFileEntry *)createDirectoryWithName:(NSString *)name
                                   error:(NSError **)outError;

- (void)deleteFileEntryWithName:(NSString *)name;

- (NSString *)uniqueNameFromString:(NSString *)string;

@end
