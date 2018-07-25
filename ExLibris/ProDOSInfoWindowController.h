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

@property(strong, readonly) PDEntry *entry;
@property(strong, readonly) NSArray *fileTypes;

- (instancetype)initWithEntry:(PDEntry *)anEntry;

@end
