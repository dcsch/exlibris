//
//  NewDiskImageController.h
//  Ex Libris
//
//  Created by David Schweinsberg on 31/12/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NewDiskImageController : NSWindowController
{
    IBOutlet NSTextField *fileNameTextField;
    IBOutlet NSComboBox *locationComboBox;
    IBOutlet NSPopUpButton *fileSystemPopUpButton;
    IBOutlet NSPopUpButton *fileFormatPopUpButton;
    IBOutlet NSPopUpButton *imageSizePopUpButton;
    NSOpenPanel *openPanel;
}

- (IBAction)chooseLocation:(id)sender;

- (IBAction)selectFileSystem:(id)sender;

- (IBAction)newDiskImage:(id)sender;

- (IBAction)cancel:(id)sender;

@end
