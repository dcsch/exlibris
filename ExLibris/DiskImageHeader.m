//
//  DiskImageHeader.m
//  Disk II
//
//  Created by David Schweinsberg on 4/01/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import "DiskImageHeader.h"


@implementation DiskImageHeader

- (id)initWithData:(NSData *)data
{
    self = [super init];
    if (self)
    {
        const unsigned char *ptr = [data bytes];
        
        // Look for the magic identifier
        if (ptr[0] == '2'
            && ptr[1] == 'I'
            && ptr[2] == 'M'
            && ptr[3] == 'G')
        {
            imageFormat = ptr[12] | (ptr[13] << 8) | (ptr[14] << 16) | (ptr[15] << 24);
            imageDataOffset = ptr[24] | (ptr[25] << 8) | (ptr[26] << 16) | (ptr[27] << 24);
            imageDataLength = ptr[28] | (ptr[29] << 8) | (ptr[30] << 16) | (ptr[31] << 24);
        }
        else
            return nil;
    }
    return self;
}

- (unsigned int)imageFormat
{
    return imageFormat;
}

- (unsigned int)imageDataOffset
{
    return imageDataOffset;
}

- (unsigned int)imageDataLength
{
    return imageDataLength;
}

@synthesize imageDataLength;
@synthesize imageDataOffset;
@synthesize imageFormat;
@end
