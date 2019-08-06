//
//  NSString+SynchromaKit.m
//  SynchromaKit
//
//  Created by David Schweinsberg on 15/02/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import "NSString+SynchromaKit.h"

@implementation NSString (SynchromaKit)

- (NSRange)rangeOfCharactersFromSet:(NSCharacterSet *)aSet {
  NSRange range = {NSNotFound, 0};
  NSUInteger i;
  for (i = 0; i < self.length; ++i) {
    unichar c = [self characterAtIndex:i];
    if ([aSet characterIsMember:c]) {
      if (range.location == NSNotFound) {
        range.location = i;
        range.length = 1;
      } else
        ++range.length;
    } else if (range.location != NSNotFound)
      break;
  }
  return range;
}

@end
