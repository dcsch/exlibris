//
//  MediaPartitionMenuDelegate.h
//  Disk II
//
//  Created by David Schweinsberg on 21/08/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MediaDevice;

@interface MediaPartitionMenuDelegate : NSObject <NSMenuDelegate> {
  MediaDevice *mediaDevice;
  NSUInteger partitionIndex;
}

- (instancetype)initWithMediaDevice:(MediaDevice *)aMediaDevice
    NS_DESIGNATED_INITIALIZER;
- (instancetype)init __attribute__((unavailable));

- (IBAction)openPartition:(id)sender;

@end
