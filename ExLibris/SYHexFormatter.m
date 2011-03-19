//
//  SYHexFormatter.m
//  SynchromaKit
//
//  Created by David Schweinsberg on 12/02/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import "SYHexFormatter.h"
#import "NSString+SynchromaKit.h"

@interface SYHexFormatter (Private)

- (NSNumber *)numberFromHexString:(NSString *)string;

@end

@implementation SYHexFormatter

- (id)init
{
    self = [super init];
    if (self)
    {
        hexDigitCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789abcdefABCDEF"];
        [hexDigitCharSet retain];
    }
    return self;
}

- (void)dealloc
{
    [hexDigitCharSet release];
    [super dealloc];
}

- (NSString *)stringForObjectValue:(id)obj
{
    if ([obj isKindOfClass:[NSString class]])
    {
        return [NSString stringWithFormat:@"$%@", obj];
    }
    else if ([obj isKindOfClass:[NSNumber class]])
    {
        NSNumber *number = obj;
        return [NSString stringWithFormat:@"$%04x", number.intValue];
    }
    return nil;
}

- (NSString *)editingStringForObjectValue:(id)obj
{
    if ([obj isKindOfClass:[NSString class]])
    {
        return obj;
    }
    else if ([obj isKindOfClass:[NSNumber class]])
    {
        NSNumber *number = obj;
        return [NSString stringWithFormat:@"%04x", number.intValue];
    }
    return nil;
}

- (BOOL)getObjectValue:(id *)obj
             forString:(NSString *)string
      errorDescription:(NSString **)errorString
{
    *obj = [self numberFromHexString:string];
    return (*obj) ? YES : NO;
}

- (NSNumber *)numberFromHexString:(NSString *)string
{
    // Trim string to only valid characters
    NSRange range = [string rangeOfCharactersFromSet:hexDigitCharSet];
    NSString *hexString = [string substringWithRange:range];
    if (!hexString)
        return nil;
    
    // Calculate the value
    NSUInteger value = 0;
    NSUInteger factor = 1;
    NSInteger i;
    for (i = [hexString length] - 1; i >= 0; --i)
    {
        unichar c = [hexString characterAtIndex:i];
        if (L'0' <= c && c <= L'9')
            value += (c - L'0') * factor;
        else if (L'a' <= c && c <= L'f')
            value += (c - L'a' + 10) * factor;
        else if (L'A' <= c && c <= L'F')
            value += (c - L'A' + 10) * factor;
        factor *= 16;
    }
    return [NSNumber numberWithUnsignedInt:value];
}

- (BOOL)isPartialStringValid:(NSString *)partialString
            newEditingString:(NSString **)newString
            errorDescription:(NSString **)error
{
    NSUInteger len = partialString.length;

    // Is the string too long?
    if (len > 4)
        return NO;

    // Are all the characters hex digits?
    NSUInteger i;
    for (i = 0; i < len; ++i)
    {
        unichar c = [partialString characterAtIndex:i];
        if (![hexDigitCharSet characterIsMember:c])
        {
            *error = @"Must be a hexidecimal value";
            return NO;
        }
    }
    
    return YES;
}

@end
