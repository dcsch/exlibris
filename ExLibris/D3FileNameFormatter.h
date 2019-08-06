//
//  D3FileNameFormatter.h
//  Disk II
//
//  Created by David Schweinsberg on 14/08/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface D3FileNameFormatter : NSFormatter {
  NSCharacterSet *lettersCharSet;
  NSCharacterSet *legalCharSet;
}

@end
