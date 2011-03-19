//
//  GraphicsBrowseController.m
//  Disk II
//
//  Created by David Schweinsberg on 14/08/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import "GraphicsBrowseController.h"


@implementation GraphicsBrowseController

- (id)initWithData:(NSData *)data
              name:(NSString *)aName
         hasHeader:(BOOL)header
{
    self = [super initWithWindowNibName:@"GraphicsBrowse"];
    if (self)
    {
        name = [aName copy];
        NSBitmapImageRep *bir = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                                                        pixelsWide:280
                                                                        pixelsHigh:192
                                                                     bitsPerSample:8
                                                                   samplesPerPixel:3
                                                                          hasAlpha:NO
                                                                          isPlanar:NO
                                                                    colorSpaceName:NSDeviceRGBColorSpace
                                                                       bytesPerRow:840
                                                                      bitsPerPixel:24];
        // Twiddle with the bits
        unsigned char *ptr = bir.bitmapData;
        const unsigned char *srcPtr = data.bytes;

        // Step past the DOS 3.x header
        if (header)
            srcPtr += 4;
        
        int i;
        for (i = 0; i < 7680; ++i)
        {
            // Extra bytes are the missing 8 bytes after each 120 bytes, thus
            // aligning to 128 bytes
            int extraBytes = i / 120 * 8;
            unsigned char srcByte = srcPtr[i + extraBytes];

            // Decode linear byte address to Apple II hires address
            int byteX = i % 40;
            int third = i / 40 % 3;
            int lineInThird = i / 120;
            int line = 8 * (lineInThird % 8) + lineInThird / 8;
            int rgbAddr = 21 * (40 * line + byteX) + 53760 * third;

//            int colorGroup = ((srcByte & 128) == 128) ? 1 : 0;
//            int j;
//            for (j = 0; j < 7; ++j)
//            {
//                int bit = 1 << j;
//                int value;
//                if ((srcByte & bit) == bit)
//                {
//                    int pixelAddr = rgbAddr + 3 * j;
//                    if (j % 2 == 0)
//                    {
//                        // Even
//                        
//                        // Is previous pixel set?
//                        if ((pixelAddr % 840 > 0)             // Are we past the leftmost pixel?
//                            && (ptr[pixelAddr - 3]
//                            || ptr[pixelAddr - 2]
//                            || ptr[pixelAddr - 1]))
//                        {
//                            // Then it and this pixel is white
//                        }
//                    }
//                    else
//                    {
//                        // Odd
//                    }
//                    value = 255;
//                }
//                else
//                    value = 0;
//                
//                ptr[rgbAddr + 3 * j] = value;
//                ptr[rgbAddr + 3 * j + 1] = value;
//                ptr[rgbAddr + 3 * j + 2] = value;
//            }
            
            // Set the hires bits
            int j;
            for (j = 0; j < 7; ++j)
            {
                int bit = 1 << j;
                int value;
                if ((srcByte & bit) == bit)
                    value = 255;
                else
                    value = 0;

                ptr[rgbAddr + 3 * j] = value;
                ptr[rgbAddr + 3 * j + 1] = value;
                ptr[rgbAddr + 3 * j + 2] = value;
            }
        }
        
        image = [[NSImage alloc] initWithSize:NSMakeSize(0, 0)];
        [image addRepresentation:bir];
        [bir release];
    }
    return self;
}

- (void)dealloc
{
    [image release];
    [super dealloc];
}

- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName
{
    NSMutableString *ms = [[[NSMutableString alloc] initWithString:name] autorelease];
    [ms appendFormat:@" (%@)", displayName];
    return ms;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    imageView.image = image;
}

@end
