//
//  DOS3xInfoController.m
//  Disk II
//
//  Created by David Schweinsberg on 14/08/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import "DOS3xInfoWindowController.h"
#import "D3FileEntry.h"
#import "D3FileNameFormatter.h"

@implementation DOS3xInfoWindowController

- (instancetype)initWithEntry:(D3FileEntry *)anEntry {
  self = [super initWithWindowNibName:@"DOS3xInfoWindow"];
  if (self) {
    entry = anEntry;
  }
  return self;
}

- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName {
  NSMutableString *ms = [[NSMutableString alloc] init];
  [ms appendFormat:@"%@ Info", entry.fileName];
  return ms;
}

- (void)windowDidLoad {
  fileNameTextField.formatter = [[D3FileNameFormatter alloc] init];
  //    auxTextField.formatter = [[[SYHexFormatter alloc] init] autorelease];
  //    auxTextField.needsDisplay = YES;
}

@end
