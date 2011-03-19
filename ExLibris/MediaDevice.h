//
//  MediaDevice.h
//  Disk II
//
//  Created by David Schweinsberg on 19/08/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define kMaxProDOSVolumeSize 0x2000000

@interface MediaDevice : NSObject
{
    NSString *path;
    NSUInteger size;
    NSUInteger partitionCount;
}

@property(copy, readonly) NSString *path;

@property(readonly) NSUInteger size;

@property(readonly) NSUInteger partitionCount;

+ (NSArray *)devices;

- (id)initWithDevicePath:(NSString *)aPath size:(NSUInteger)aSize;

//- (NSData *)partitionAtIndex:(NSUInteger)index;

@end
