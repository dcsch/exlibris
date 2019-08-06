//
//  MediaDevice.m
//  Disk II
//
//  Created by David Schweinsberg on 19/08/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import "MediaDevice.h"
#import <IOKit/IOKitLib.h>
#import <IOKit/storage/IOMedia.h>
#include <util.h>

@implementation MediaDevice

- (instancetype)initWithDevicePath:(NSString *)aPath size:(NSUInteger)aSize {
  self = [super init];
  if (self) {
    path = [aPath copy];
    size = aSize;

    // Calculate the number of partitions
    partitionCount = size / kMaxProDOSVolumeSize;
    if (size % kMaxProDOSVolumeSize > 0)
      ++partitionCount;
  }
  return self;
}

//- (NSData *)partitionAtIndex:(NSUInteger)index
//{
//    if (index > partitionCount - 1)
//        return nil;
//
//    int fd = open(path.UTF8String, O_RDONLY);
//    if (fd > -1)
//    {
//        off_t pos = kMaxProDOSVolumeSize * index;
//        ssize_t len;
//        if (index < partitionCount - 1)
//            len = kMaxProDOSVolumeSize;
//        else
//            len = size - pos;
//        NSMutableData *data = [NSMutableData dataWithLength:len];
//
//        lseek(fd, pos, SEEK_SET);
//        ssize_t bytesRead = read(fd, data.mutableBytes, len);
//        close(fd);
//
//        NSLog(@"Read %d bytes from %@ @ %d", bytesRead, path, pos);
//
//        return data;
//    }
//    return nil;
//}

+ (NSArray *)devices {
  NSMutableArray *mediaDevices = [NSMutableArray arrayWithCapacity:1];

  // Create a matching dictionary for an IOMedia class, which is a 'whole'
  // volume
  // (rather than a virtual, or partition), is a 'leaf' (that is, at the end of
  // the
  // heirarchy) and in removable.
  CFMutableDictionaryRef mediaMatchDictionary =
      IOServiceMatching(kIOMediaClass);
  CFDictionaryAddValue(mediaMatchDictionary, CFSTR(kIOMediaWholeKey),
                       kCFBooleanTrue);
  CFDictionaryAddValue(mediaMatchDictionary, CFSTR(kIOMediaLeafKey),
                       kCFBooleanTrue);
  CFDictionaryAddValue(mediaMatchDictionary, CFSTR(kIOMediaRemovableKey),
                       kCFBooleanTrue);

  io_iterator_t iterator;
  IOServiceGetMatchingServices(kIOMasterPortDefault, mediaMatchDictionary,
                               &iterator);

  io_object_t obj;
  while ((obj = IOIteratorNext(iterator))) {
    CFStringRef nameRef = IORegistryEntryCreateCFProperty(
        obj, CFSTR("BSD Name"), kCFAllocatorDefault, 0);
    CFNumberRef sizeRef = IORegistryEntryCreateCFProperty(
        obj, CFSTR("Size"), kCFAllocatorDefault, 0);
    NSString *path =
        [NSString stringWithFormat:@"/dev/%@", (__bridge NSString *)nameRef];
    [mediaDevices
        addObject:[[MediaDevice alloc]
                      initWithDevicePath:path
                                    size:((__bridge NSNumber *)sizeRef)
                                             .unsignedIntegerValue]];
    NSLog(@"Found: %@", (__bridge NSString *)nameRef);
    CFRelease(nameRef);
    CFRelease(sizeRef);

    IOObjectRelease(obj);
  }
  IOObjectRelease(iterator);

  NSLog(@"Done searching for media");

  return mediaDevices;
}

@synthesize path;

@synthesize size;

@synthesize partitionCount;

@end
