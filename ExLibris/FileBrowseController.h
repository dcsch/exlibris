//
//  FileBrowseController.h
//  Disk II
//
//  Created by David Schweinsberg on 10/01/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FileBrowseController : NSWindowController {
  IBOutlet NSPopUpButton *popUpButton;
  IBOutlet NSTextView *textView;
  NSData *data;
  NSUInteger startAddress;
  NSString *name;
  NSUInteger typeId;
  BOOL header;
}

- (instancetype)initWithData:(NSData *)aData
                startAddress:(NSUInteger)aStartAddress
                        name:(NSString *)aName
                      typeId:(NSUInteger)aTypeId
                   hasHeader:(BOOL)aHeader;

- (void)hexDump;

- (void)catalog;

- (IBAction)displayHexDump:(id)sender;

- (IBAction)displayApplesoftBasic:(id)sender;

- (IBAction)display6502Disassembly:(id)sender;

- (IBAction)displayText:(id)sender;

- (IBAction)displayCatalog:(id)sender;

@end
