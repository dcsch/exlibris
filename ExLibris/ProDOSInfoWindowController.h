//
//  ProDOSInfoWindowController.h
//  Disk II
//
//  Created by David Schweinsberg on 4/01/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PDEntry;

@interface ProDOSInfoWindowController : NSWindowController
{
    IBOutlet NSTextField *fileNameTextField;
    IBOutlet NSPopUpButton *typePopUpButton;
    IBOutlet NSTextField *auxTextField;
    PDEntry *entry;
}

@property(retain, readonly) PDEntry *entry;
@property(retain, readonly) NSArray *fileTypes;

- (id)initWithEntry:(PDEntry *)anEntry;

@end
