//
//  ProDOSInfoWindowController.m
//  Disk II
//
//  Created by David Schweinsberg on 4/01/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import "ProDOSInfoWindowController.h"
#import "DiskImage.h"
#import "ProDOSWindowController.h"
#import "PDFileEntry.h"
#import "PDFileType.h"
#import "PDFileNameFormatter.h"
#import "SYHexFormatter.h"

@implementation ProDOSInfoWindowController

- (instancetype)initWithEntry:(PDEntry *)anEntry
{
    self = [super initWithWindowNibName:@"ProDOSInfoWindow"];
    if (self)
    {
        entry = anEntry;
    }
    return self;
}


- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName
{
    NSMutableString *ms = [[NSMutableString alloc] init];
    [ms appendFormat:@"%@ Info", entry.fileName];
    return ms;
}

- (void)windowDidLoad
{
    fileNameTextField.formatter = [[PDFileNameFormatter alloc] init];
    auxTextField.formatter = [[SYHexFormatter alloc] init];
    auxTextField.needsDisplay = YES;
}

- (id)valueForUndefinedKey:(NSString *)key
{
    NSLog(@"Undefined key: %@", key);
    return nil;
}

@synthesize entry;

- (NSArray *)fileTypes
{
    return [PDFileType fileTypes];
}

@end
