//
//  PDFileNameFormatter.m
//  Disk II
//
//  Created by David Schweinsberg on 3/03/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import "PDFileNameFormatter.h"

@implementation PDFileNameFormatter

- (instancetype)init {
  self = [super init];
  if (self) {
    lettersCharSet = [NSCharacterSet
        characterSetWithCharactersInString:
            @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"];
    legalCharSet = [NSCharacterSet
        characterSetWithCharactersInString:
            @".0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"];
  }
  return self;
}

- (NSString *)stringForObjectValue:(id)obj {
  if ([obj isKindOfClass:[NSString class]]) {
    return obj;
  }
  return nil;
}

- (BOOL)getObjectValue:(id *)obj
             forString:(NSString *)string
      errorDescription:(NSString **)errorString {
  *obj = string.uppercaseString;
  return YES;
}

- (BOOL)isPartialStringValid:(NSString *)partialString
            newEditingString:(NSString **)newString
            errorDescription:(NSString **)error {
  NSUInteger len = partialString.length;
  if (len == 0)
    return YES;

  // First character must be a letter
  unichar c = [partialString characterAtIndex:0];
  if (![lettersCharSet characterIsMember:c]) {
    *error = @"First character of a ProDOS file name must be a letter";
    return NO;
  }

  // Is the string too long?
  if (len > 15) {
    *error = @"Too long for a ProDOS file name";
    return NO;
  }

  // Are all the characters legal?
  NSUInteger i;
  for (i = 0; i < len; ++i) {
    unichar c = [partialString characterAtIndex:i];
    if (![legalCharSet characterIsMember:c]) {
      *error = @"Illegal character for a ProDOS file name";
      return NO;
    }
  }

  return YES;
}

@end
