//
//  DiskImageHeader.h
//  Disk II
//
//  Created by David Schweinsberg on 4/01/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DiskImageHeader : NSObject
{
    unsigned int imageFormat;
    unsigned int imageDataOffset;
    unsigned int imageDataLength;
}

- (instancetype)initWithData:(NSData *)data NS_DESIGNATED_INITIALIZER;
- (instancetype)init __attribute__((unavailable));
@property (readonly) unsigned int imageFormat;
@property (readonly) unsigned int imageDataOffset;
@property (readonly) unsigned int imageDataLength;

//@property (getter=imageDataLength) unsigned int imageDataLength;
//@property (getter=imageDataOffset) unsigned int imageDataOffset;
//@property (getter=imageFormat) unsigned int imageFormat;
@end
