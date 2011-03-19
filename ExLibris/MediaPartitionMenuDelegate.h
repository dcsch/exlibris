//
//  MediaPartitionMenuDelegate.h
//  Disk II
//
//  Created by David Schweinsberg on 21/08/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MediaDevice;

@interface MediaPartitionMenuDelegate : NSObject
{
    MediaDevice *mediaDevice;
    NSUInteger partitionIndex;
}

- (id)initWithMediaDevice:(MediaDevice *)aMediaDevice;

- (IBAction)openPartition:(id)sender;

@end
