//
//  MediaMenuDelegate.m
//  Disk II
//
//  Created by David Schweinsberg on 18/08/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import "MediaMenuDelegate.h"
#import "MediaDevice.h"
#import "MediaPartitionMenuDelegate.h"

@implementation MediaMenuDelegate


- (NSInteger)numberOfItemsInMenu:(NSMenu *)menu
{
    mediaDeviceArray = [MediaDevice devices];
    return (mediaDeviceArray.count > 0) ? mediaDeviceArray.count : 1;
}

- (BOOL)menu:(NSMenu *)menu
  updateItem:(NSMenuItem *)item
     atIndex:(int)x
shouldCancel:(BOOL)shouldCancel
{
    if (mediaDeviceArray.count == 0)
    {
        item.title = @"No media found";
        return NO;
    }

    MediaDevice *md = mediaDeviceArray[x];
    
    // Set up the menu item
    item.title = md.path;

    // Add a submenu listing the partitions
    NSMenu *submenu = [[NSMenu alloc] initWithTitle:item.title];
    MediaPartitionMenuDelegate *delegate = [[MediaPartitionMenuDelegate alloc] initWithMediaDevice:md];
    submenu.delegate = delegate;
    item.submenu = submenu;
    
    return YES;
}

@end
