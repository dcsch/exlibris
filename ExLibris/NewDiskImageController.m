//
//  NewDiskImageController.m
//  Ex Libris
//
//  Created by David Schweinsberg on 31/12/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import "NewDiskImageController.h"
#import "DiskImage.h"
#import "DiskII.h"

@interface NewDiskImageController (Private)

- (void)openPanelDidEnd:(NSOpenPanel *)panel
             returnCode:(int)returnCode
            contextInfo:(void *)contextInfo;

- (void)selectProDOS;

- (void)selectDOS33;

@end

@implementation NewDiskImageController

- (id)init
{
    self = [super initWithWindowNibName:@"NewDiskImage"];
    if (self)
    {
    }
    return self;
}

- (void)windowDidLoad
{
    //[(NSPanel *)self.window setFloatingPanel:YES];

    fileNameTextField.stringValue = @"untitled.2mg";
    
    [fileSystemPopUpButton removeAllItems];
    [fileSystemPopUpButton addItemWithTitle:@"ProDOS"];
    [fileSystemPopUpButton addItemWithTitle:@"DOS 3.3"];
    
    [self selectProDOS];

    [super windowDidLoad];
}

- (IBAction)chooseLocation:(id)sender
{
    openPanel = [NSOpenPanel openPanel];
    openPanel.canChooseFiles = NO;
    openPanel.canChooseDirectories = YES;
    openPanel.canCreateDirectories = YES;
    openPanel.prompt = @"Choose";
    [openPanel beginSheetForDirectory:nil
                                 file:nil
                       modalForWindow:self.window
                        modalDelegate:self
                       didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:)
                          contextInfo:NULL];
}

- (IBAction)selectFileSystem:(id)sender
{
    NSMenuItem *item = [fileSystemPopUpButton selectedItem];
    if ([item.title isEqualToString:@"ProDOS"])
    {
        [self selectProDOS];
    }
    else if ([item.title isEqualToString:@"DOS 3.3"])
    {
        [self selectDOS33];
    }
}

- (IBAction)newDiskImage:(id)sender
{
    NSDocumentController* documentController = [NSDocumentController sharedDocumentController];
    NSError *error;

    // What document type are we creating?
    NSString *docType;
    NSMenuItem *item = [fileSystemPopUpButton selectedItem];
    if ([item.title isEqualToString:@"ProDOS"])
        docType = ELAppleProDOSDiskImageDocumentType;
    else if ([item.title isEqualToString:@"DOS 3.3"])
        docType = ELAppleDOS33DiskImageDocumentType;
    
    // What size?
    NSUInteger blockCount = 0;
    if (docType == ELAppleProDOSDiskImageDocumentType)
    {
        NSMenuItem *item = [imageSizePopUpButton selectedItem];
        if ([item.title isEqualToString:@"140 KB"])
            blockCount = 280;
        else if ([item.title isEqualToString:@"800 KB"])
            blockCount = 1600;
        else if ([item.title isEqualToString:@"32 MB"])
            blockCount = 65536;
    }
    
    // Create the requested disk image
    NSDocument *document = [documentController makeUntitledDocumentOfType:docType
                                                                    error:&error];
    if (document)
    {
        DiskImage *diskImage = (DiskImage *)document;
        diskImage.blockCount = blockCount;

        [documentController addDocument:document];
        [document makeWindowControllers];
        [document showWindows];
    }

    // Close this window
    [self.window performClose:self];
}

- (IBAction)cancel:(id)sender
{
    [self.window performClose:self];
}

- (void)openPanelDidEnd:(NSOpenPanel *)panel
             returnCode:(int)returnCode
            contextInfo:(void *)contextInfo
{
    NSString *dirName = [openPanel.filenames objectAtIndex:0];
    locationComboBox.stringValue = [dirName stringByAbbreviatingWithTildeInPath];
}

- (void)selectProDOS
{
    [fileFormatPopUpButton removeAllItems];
    [fileFormatPopUpButton addItemWithTitle:@"2IMG (.2mg)"];
    [fileFormatPopUpButton addItemWithTitle:@"ProDOS-ordered (.po)"];
    
    [imageSizePopUpButton removeAllItems];
    [imageSizePopUpButton addItemWithTitle:@"140 KB"];
    [imageSizePopUpButton addItemWithTitle:@"800 KB"];
    [imageSizePopUpButton addItemWithTitle:@"32 MB"];
}

- (void)selectDOS33
{
    [fileFormatPopUpButton removeAllItems];
    [fileFormatPopUpButton addItemWithTitle:@"2IMG (.2mg)"];
    [fileFormatPopUpButton addItemWithTitle:@"DOS-ordered (.do)"];
    
    [imageSizePopUpButton removeAllItems];
    [imageSizePopUpButton addItemWithTitle:@"140 KB"];
}

@end
