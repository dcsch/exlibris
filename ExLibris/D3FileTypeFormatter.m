//
//  D3FileTypeFormatter.m
//  Disk II
//
//  Created by David Schweinsberg on 10/08/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import "D3FileTypeFormatter.h"


@implementation D3FileTypeFormatter

- (instancetype)init
{
    self = [super init];
    if (self)
    {
    }
    return self;
}


- (NSString *)stringForObjectValue:(id)obj
{
    if ([obj isKindOfClass:[NSNumber class]])
    {
        NSNumber *fileType = obj;
        switch (fileType.unsignedIntegerValue)
        {
            case 0x00:
                return @"T";
            case 0x01:
                return @"I";
            case 0x02:
                return @"A";
            case 0x04:
                return @"B";
            case 0x08:
                return @"S";
            case 0x10:
                return @"R";
            case 0x20:
                return @"A";
            case 0x40:
                return @"B";
            default:
                return @"-";
        }
    }
    return nil;
}

- (BOOL)getObjectValue:(id *)obj
             forString:(NSString *)string
      errorDescription:(NSString **)errorString
{
    return NO;
}

@end
