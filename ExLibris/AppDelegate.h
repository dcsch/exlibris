//
//  AppDelegate.h
//  Disk II
//
//  Created by David Schweinsberg on 1/01/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PreferencesWindowController;
@class DiskImageController;

@interface AppDelegate : NSObject
{
    PreferencesWindowController *preferenceController;
    DiskImageController *diskImageController;
}

- (IBAction)showPreferencePanel:(id)sender;

@end
