//
//  SYHexFormatter.h
//  SynchromaKit
//
//  Created by David Schweinsberg on 12/02/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SYHexFormatter : NSFormatter {
  NSCharacterSet *hexDigitCharSet;
}

@end
