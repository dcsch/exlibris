//
//  D3Catalog.h
//  Disk II
//
//  Created by David Schweinsberg on 10/08/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class D3Volume;

@interface D3Catalog : NSObject
{
    NSMutableArray *sectors;
    NSMutableArray *entries;
}

@property(retain, readonly) NSArray *entries;

- (id)initWithVolume:(D3Volume *)volume;

@end
