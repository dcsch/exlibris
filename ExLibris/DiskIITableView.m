//
//  DiskIITableView.m
//  Disk II
//
//  Created by David Schweinsberg on 14/08/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import "DiskIITableView.h"

@implementation DiskIITableView

// We override this so that we can ensure the right-clicked row is selected
// before we show the context menu
- (NSMenu *)menuForEvent:(NSEvent *)event
{
    // Find which row is under the cursor
    [self.window makeFirstResponder:self];
    NSPoint menuPoint = [self convertPoint:event.locationInWindow fromView:nil];
    NSInteger row = [self rowAtPoint:menuPoint];

    // Update the table selection before showing menu
    // Preserves the selection if the row under the mouse is selected (to allow for
    // multiple items to be selected), otherwise selects the row under the mouse
    BOOL currentRowIsSelected = [self.selectedRowIndexes containsIndex:row];
    if (!currentRowIsSelected)
        [self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];

    if (self.numberOfSelectedRows <= 0)
    {
        // No rows are selected, so the table should be displayed with all items disabled
        NSMenu* tableViewMenu = [self.menu copy];
        int i;
        for (i = 0; i < tableViewMenu.numberOfItems; ++i)
            [[tableViewMenu itemAtIndex:i] setEnabled:NO];
        return tableViewMenu;
    }
    else
        return self.menu;
}

@end
