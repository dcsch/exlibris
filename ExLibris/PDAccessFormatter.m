//
//  PDAccessFormatter.m
//  Disk II
//
//  Created by David Schweinsberg on 17/03/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import "PDAccessFormatter.h"

@implementation PDAccessFormatter

- (NSString *)stringForObjectValue:(id)obj {
  if ([obj isKindOfClass:[NSNumber class]]) {
    NSMutableString *str = [NSMutableString string];
    NSInteger access = [obj integerValue];
    if (access & 0x80)
      [str appendString:@"d"];
    if (access & 0x40)
      [str appendString:@"n"];
    if (access & 0x20)
      [str appendString:@"b"];
    if (access & 0x02)
      [str appendString:@"w"];
    if (access & 0x01)
      [str appendString:@"r"];
    return str;
  }
  return nil;
}

- (BOOL)getObjectValue:(id *)obj
             forString:(NSString *)string
      errorDescription:(NSString **)errorString {
  // TODO: This should be able to intepret the letters used above
  NSInteger access = string.integerValue;
  *obj = @(access);
  return YES;
}

@end
