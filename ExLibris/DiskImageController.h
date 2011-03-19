//
//  DiskImageController.h
//  Ex Libris
//
//  Created by David Schweinsberg on 18/12/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum _ELDiskImageExtension
{
    ELUnknownExtension,
    EL2imgExtension,
    ELDskExtension
} ELDiskImageExtension;

@interface DiskImageController : NSDocumentController
{
    NSWindowController *newDiskImageController;
}

+ (ELDiskImageExtension)extensionForUrl:(NSURL *)url;

@end
