//
//  Error.m
//  Ex Libris
//
//  Created by David Schweinsberg on 5/12/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import "Error.h"
#import "ExLibrisErrors.h"

@implementation Error

- (id)initWithCode:(NSInteger)code
{
    NSString *descrip = nil;
    switch (code)
    {
        case ELVolumeDirectoryEntryLimitError:
            descrip = NSLocalizedString(@"Volume directory has reached its maximum number of entries.", @"");
            break;

        case ELVolumeSpaceLimitError:
            descrip = NSLocalizedString(@"There is not enough space on the volume.", @"");
            break;
    }
    NSDictionary *errDict = [NSDictionary dictionaryWithObject:descrip
                                                        forKey:NSLocalizedDescriptionKey];
    return [super initWithDomain:ELErrorDomain code:code userInfo:errDict];
}

+ (id)errorWithCode:(NSInteger)code
{
    return [[[Error alloc] initWithCode:code] autorelease];
}

@end
