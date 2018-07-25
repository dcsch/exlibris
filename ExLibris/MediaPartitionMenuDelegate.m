//
//  MediaPartitionMenuDelegate.m
//  Disk II
//
//  Created by David Schweinsberg on 21/08/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import "MediaPartitionMenuDelegate.h"
#import "MediaDevice.h"

@implementation MediaPartitionMenuDelegate

- (instancetype)initWithMediaDevice:(MediaDevice *)aMediaDevice
{
    self = [super init];
    if (self)
    {
        mediaDevice = aMediaDevice;
    }
    return self;
}


#pragma mark - NSMenuDelegate Methods

- (NSInteger)numberOfItemsInMenu:(NSMenu *)menu
{
    return mediaDevice.partitionCount;
}

- (BOOL)menu:(NSMenu *)menu
  updateItem:(NSMenuItem *)item
     atIndex:(NSInteger)x
shouldCancel:(BOOL)shouldCancel
{
    item.title = [NSString stringWithFormat:@"Partition %ld", (long)x];
    item.tag = x;
    item.target = self;
    item.action = @selector(openPartition:);
    return YES;
}

#pragma mark - Actions

- (IBAction)openPartition:(id)sender
{
    NSMenuItem *item = sender;
    NSString *pathWithPartition = [NSString stringWithFormat:@"%@/%ld", mediaDevice.path, (long)item.tag];
    NSURL *url = [NSURL fileURLWithPath:pathWithPartition];
    NSDocumentController *dc = [NSDocumentController sharedDocumentController];
    [dc openDocumentWithContentsOfURL:url display:YES completionHandler:^(NSDocument * _Nullable document, BOOL documentWasAlreadyOpen, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Failed to open partition: %@", url);
        } else {
            NSLog(@"Open partition: %@", url);
        }
    }];
}

@end
