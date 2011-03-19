//
//  ResourceManager.h
//  Disk II
//
//  Created by David Schweinsberg on 17/01/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreServices/CoreServices.h>

@interface ResourceManager : NSObject
{
    FSRef fsRef;
    short refNum;
}

- (id)initWithURL:(NSURL *)fileURL;

@property short refNum;
@end
