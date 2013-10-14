//
//  AppDelegate.m
//  Disk II
//
//  Created by David Schweinsberg on 1/01/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import "AppDelegate.h"
#import "PreferencesWindowController.h"
#import "DiskImageController.h"
#import "DiskII.h"

@implementation AppDelegate

+ (void)initialize
{
    NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
    
    // Set defaults
    defaultValues[ShowAllDirectoryEntriesKey] = @NO;
    
    // Register the defaults
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}


- (IBAction)showPreferencePanel:(id)sender
{
    if (!preferenceController)
        preferenceController = [[PreferencesWindowController alloc] init];
    [preferenceController showWindow:self];
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
    // Create our custom NSDocumentController
    diskImageController = [[DiskImageController alloc] init];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
}

- (BOOL)applicationOpenUntitledFile:(NSApplication *)theApplication
{
    return NO;
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
    return NO;
}

@end
