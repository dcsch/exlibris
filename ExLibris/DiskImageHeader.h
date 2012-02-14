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

- (id)initWithData:(NSData *)data;
- (unsigned int)imageFormat;
- (unsigned int)imageDataOffset;
- (unsigned int)imageDataLength;

//@property (getter=imageDataLength) unsigned int imageDataLength;
//@property (getter=imageDataOffset) unsigned int imageDataOffset;
//@property (getter=imageFormat) unsigned int imageFormat;
@end
