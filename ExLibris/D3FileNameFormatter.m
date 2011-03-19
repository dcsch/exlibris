//
//  D3FileNameFormatter.m
//  Disk II
//
//  Created by David Schweinsberg on 14/08/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import "D3FileNameFormatter.h"

@implementation D3FileNameFormatter

- (id)init
{
    self = [super init];
    if (self)
    {
        lettersCharSet = [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"] retain];
        legalCharSet = [[NSCharacterSet characterSetWithCharactersInString:@" !\"#$%&'()*+-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_abcdefghijklmnopqrstuvwxyz"] retain];
    }
    return self;
}

- (void)dealloc
{
    [lettersCharSet release];
    [legalCharSet release];
    [super dealloc];
}

- (NSString *)stringForObjectValue:(id)obj
{
    if ([obj isKindOfClass:[NSString class]])
    {
        return obj;
    }
    return nil;
}

- (BOOL)getObjectValue:(id *)obj
             forString:(NSString *)string
      errorDescription:(NSString **)errorString
{
    *obj = string.uppercaseString;
    return YES;
}

- (BOOL)isPartialStringValid:(NSString *)partialString
            newEditingString:(NSString **)newString
            errorDescription:(NSString **)error
{
    NSUInteger len = partialString.length;
    if (len == 0)
        return YES;
    
    // First character must be a letter
    unichar c = [partialString characterAtIndex:0];
    if (![lettersCharSet characterIsMember:c])
    {
        *error = @"First character of a DOS 3.x file name must be a letter";
        return NO;
    }
    
    // Is the string too long?
    if (len > 30)
    {
        *error = @"Too long for a DOS 3.x file name";
        return NO;
    }
    
    // Are all the characters legal?
    NSUInteger i;
    for (i = 0; i < len; ++i)
    {
        unichar c = [partialString characterAtIndex:i];
        if (![legalCharSet characterIsMember:c])
        {
            *error = @"Illegal character for a DOS 3.x file name";
            return NO;
        }
    }
    
    return YES;
}

@end
