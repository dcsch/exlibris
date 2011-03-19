//
//  ResourceManager.m
//  Disk II
//
//  Created by David Schweinsberg on 17/01/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import "ResourceManager.h"


@implementation ResourceManager

- (id)initWithURL:(NSURL *)fileURL
{
    self = [super init];
    if (self)
    {
        // Convert URL to path, and then to FSRef
        NSString *path = [fileURL path];
        FSPathMakeRef((const UInt8 *)[path cStringUsingEncoding:[NSString defaultCStringEncoding]],
                      &fsRef,
                      NULL);
        
        refNum = FSOpenResFile(&fsRef, 0);
        OSErr err = ResError();
        NSLog(@"ResError: %d", err);
    }
    return self;
}

- (void)dealloc
{
    CloseResFile(refNum);
    [super dealloc];
}

@synthesize refNum;
@end
