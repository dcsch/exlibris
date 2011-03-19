//
//  ProDOSImageController.h
//  Disk II
//
//  Created by David Schweinsberg on 1/01/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PDEntry;

@interface ProDOSWindowController : NSWindowController
{
    IBOutlet NSOutlineView *catalogOutlineView;
    IBOutlet NSTreeController *catalogTreeController;
    IBOutlet NSTabView *tabView;
    IBOutlet NSSearchField *searchField;
    
    NSMutableDictionary *windowControllers;
}

- (IBAction)copy:(id)sender;

- (IBAction)paste:(id)sender;

- (IBAction)delete:(id)sender;

- (IBAction)openGraphics:(id)sender;

- (IBAction)getInfo:(id)sender;

- (IBAction)createSubdirectory:(id)sender;

- (IBAction)viewFile:(id)sender;

- (IBAction)enterSearchQuery:(id)sender;

- (void)showFileBrowse:(NSArray *)entries;

- (void)handleShowAllDirectoryEntriesChange:(NSNotification *)note;

@end
