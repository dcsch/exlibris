//
//  PreferenceController.m
//  Disk II
//
//  Created by David Schweinsberg on 15/11/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import "PreferencesWindowController.h"
#import "DiskII.h"

@implementation PreferencesWindowController

- (instancetype)init
{
    self = [super initWithWindowNibName:@"PreferencesWindow"];
    return self;
}

- (BOOL)showAllDirectoryEntries
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:ShowAllDirectoryEntriesKey];
}

- (void)setShowAllDirectoryEntries:(BOOL)flag
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@(flag)
                 forKey:ShowAllDirectoryEntriesKey];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:ShowAllDirectoryEntriesChanged object:self];
}

@end
