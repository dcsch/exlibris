//
//  PDFileEntry+DiskII.m
//  Disk II
//
//  Created by David Schweinsberg on 30/04/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import "PDFileEntry+DiskII.h"
#import "PDDirectory.h"

@implementation PDFileEntry (DiskII)

- (NSColor *)textColor
{
    if (self.storageType == 0)
        return [NSColor grayColor];

    // Use the default text colour for file entries
    return nil;
}

@end
