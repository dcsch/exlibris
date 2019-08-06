//
//  DOS3xImageController.h
//  Disk II
//
//  Created by David Schweinsberg on 10/08/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class D3FileEntry;

@interface DOS3xWindowController : NSWindowController {
  IBOutlet NSTableView *catalogTableView;
  IBOutlet NSArrayController *catalogArrayController;

  NSMutableDictionary *windowControllers;
}

- (IBAction)openGraphics:(id)sender;

- (IBAction)getInfo:(id)sender;

- (void)showFileBrowse:(NSArray *)entries;

@end
