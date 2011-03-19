//
//  DOS3xImageController.m
//  Disk II
//
//  Created by David Schweinsberg on 10/08/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import "DOS3xWindowController.h"
#import "D3FileTypeFormatter.h"
#import "D3FileEntry.h"
#import "D3Volume.h"
#import "D3Catalog.h"
#import "DOS3xImage.h"
#import "FileBrowseController.h"
#import "GraphicsBrowseController.h"
#import "PDFileType.h"
#import "DOS3xInfoWindowController.h"
#import "DiskII.h"

@interface DOS3xWindowController (Private)

- (D3FileEntry *)selectedEntry;

@end

@implementation DOS3xWindowController

- (id)init
{
    self = [super initWithWindowNibName:@"DOS3xWindow"];
    if (self)
    {
        // When the user closes the volume window, we want all other windows
        // attached to the volume (file browsers, etc) to close also
        [self setShouldCloseDocument:YES];
        
        // Other controllers accessing this document
        windowControllers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [windowControllers release];
    [super dealloc];
}

- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName
{
    DOS3xImage *image = self.document;
    D3Volume *volume = (D3Volume *)image.volume;
    NSMutableString *ms = [[[NSMutableString alloc] init] autorelease];
    [ms appendFormat:@"Volume %d (%@)", volume.number, displayName];
    return ms;
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    // Attach some custom formatters to the outline view
    NSTableColumn *column = [catalogTableView.tableColumns objectAtIndex:1];
    [column.dataCell setFormatter:[[[D3FileTypeFormatter alloc] init] autorelease]];
    [catalogTableView setNeedsDisplay:YES];
}

- (IBAction)openGraphics:(id)sender
{
    D3FileEntry *entry = self.selectedEntry;
    if (entry)
    {
        // Is window already being shown?
        NSString *key = [NSString stringWithFormat:@"%@ Graphics", entry.description];
        NSWindowController *windowController = [windowControllers objectForKey:key];
        if (!windowController)
        {
            DOS3xImage *di = self.document;
            D3Volume *volume = (D3Volume *)di.volume;
            NSData *data = [volume dataForEntry:entry];
            windowController = [[GraphicsBrowseController alloc] initWithData:data
                                                                         name:entry.fileName
                                                                    hasHeader:YES];
            [windowControllers setObject:windowController forKey:key];
            [self.document addWindowController:windowController];
        }
        [windowController showWindow:self];
    }
}

- (IBAction)getInfo:(id)sender
{
    D3FileEntry *entry = self.selectedEntry;
    if (entry)
    {
        // Is info already being shown?
        NSString *key = [NSString stringWithFormat:@"%@ Info", entry.description];
        NSWindowController *windowController = [windowControllers objectForKey:key];
        if (!windowController)
        {
            windowController = [[DOS3xInfoWindowController alloc] initWithEntry:entry];
            [windowControllers setObject:windowController forKey:key];
            [self.document addWindowController:windowController];
        }
        [windowController showWindow:self];
    }
}

- (void)showFileBrowse:(NSArray *)entries
{
    D3FileEntry *entry = [entries objectAtIndex:0];
    if (entry)
    {
        DOS3xImage *di = self.document;
        D3Volume *volume = (D3Volume *)di.volume;
        NSData *data = [volume dataForEntry:entry];
        
        // Is this file already being browsed?  If so, it will appear in our
        // list of fileBrowseControllers.
        NSString *key = [NSString stringWithFormat:@"%@ File", entry.description];
        NSWindowController *windowController = [windowControllers objectForKey:key];
        if (!windowController)
        {
            // NOTE: The following alert code does nothing at this stage, since the
            // FileBrowseController will always succeed.  If the storage type is
            // unhandled, then there will be a message reporting as such in the
            // file browser.
            
            // Convert the DOS 3.x file type to a ProDOS type id, as this is
            // what the FileBrowseController recognises
            NSUInteger typeId = 0;
            NSUInteger startAddress = 0;
            switch (entry.fileType)
            {
                case TEXT_FILE:
                    typeId = TEXT_FILE_TYPE_ID;
                    break;
                case INTEGER_BASIC_FILE:
                    typeId = INTEGER_BASIC_FILE_TYPE_ID;
                    break;
                case APPLESOFT_BASIC_FILE:
                    typeId = APPLESOFT_BASIC_FILE_TYPE_ID;
                    break;
                case BINARY_FILE:
                {
                    typeId = BINARY_FILE_TYPE_ID;
                    const unsigned char* ptr = [data bytes];
                    startAddress = unpackWord(ptr);
                    break;
                }
            }
                    
            windowController = [[FileBrowseController alloc] initWithData:data
                                                             startAddress:startAddress
                                                                     name:entry.fileName
                                                                   typeId:typeId
                                                                hasHeader:YES];
            if (windowController)
            {
                [windowControllers setObject:windowController forKey:key];
                [self.document addWindowController:windowController];
            }
            else
                [NSAlert alertWithMessageText:@"Unhandled storage type"
                                defaultButton:nil
                              alternateButton:nil
                                  otherButton:nil
                    informativeTextWithFormat:nil];
        }
        [windowController showWindow:self];
        
        NSLog(@"Browsing: %@", entry.fileName);
    }
}

- (D3FileEntry *)selectedEntry
{
    NSArray *selectedObjects = catalogArrayController.selectedObjects;
    if (selectedObjects.count > 0)
        return [selectedObjects objectAtIndex:0];
    return nil;
}

@end
