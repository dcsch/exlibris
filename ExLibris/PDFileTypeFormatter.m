//
//  PDFileTypeFormatter.m
//  Disk II
//
//  Created by David Schweinsberg on 16/03/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import "PDFileTypeFormatter.h"
#import "PDFileType.h"

@implementation PDFileTypeFormatter

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
    if ([obj isKindOfClass:[PDFileType class]])
    {
        PDFileType *fileType = obj;
        //return fileType.name;
        return fileType.nameOrTypeId;
    }
    return nil;
}

- (BOOL)getObjectValue:(id *)obj
             forString:(NSString *)string
      errorDescription:(NSString **)errorString
{
    NSInteger fileTypeId = string.integerValue;
    *obj = [PDFileType fileTypeWithId:fileTypeId];
    return YES;
}

//- (BOOL)isPartialStringValid:(NSString *)partialString
//            newEditingString:(NSString **)newString
//            errorDescription:(NSString **)error
//{
//}

@end
