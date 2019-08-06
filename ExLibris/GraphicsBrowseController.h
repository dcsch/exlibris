//
//  GraphicsBrowseController.h
//  Disk II
//
//  Created by David Schweinsberg on 14/08/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GraphicsBrowseController : NSWindowController {
  IBOutlet NSImageView *imageView;
  NSImage *image;
  NSString *name;
}

- (instancetype)initWithData:(NSData *)data
                        name:(NSString *)aName
                   hasHeader:(BOOL)header;

@end
