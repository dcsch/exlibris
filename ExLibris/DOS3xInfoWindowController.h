//
//  DOS3xInfoController.h
//  Disk II
//
//  Created by David Schweinsberg on 14/08/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class D3FileEntry;

@interface DOS3xInfoWindowController : NSWindowController
{
    IBOutlet NSTextField *fileNameTextField;
    D3FileEntry *entry;
}

- (instancetype)initWithEntry:(D3FileEntry *)anEntry;

@end
