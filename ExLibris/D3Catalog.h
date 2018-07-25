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

@property(strong, readonly) NSArray *entries;

- (instancetype)initWithVolume:(D3Volume *)volume NS_DESIGNATED_INITIALIZER;
- (instancetype)init __attribute__((unavailable));

@end
