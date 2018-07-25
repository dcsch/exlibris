//
//  PDFileType.m
//  Disk II
//
//  Created by David Schweinsberg on 9/02/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import "PDFileType.h"

static NSMutableDictionary *fileTypes;

@implementation PDFileType

+ (NSDictionary *)fileTypeDictionary
{
    // Check if we have to set up the file types dictionary
    if (!fileTypes)
    {
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"FileTypes" withExtension:@"plist"];
        NSData *data = [NSData dataWithContentsOfURL:url];
        NSPropertyListFormat format;
        NSError *error;
        NSArray *plist = [NSPropertyListSerialization propertyListWithData:data
                                                                   options:NSPropertyListImmutable
                                                                    format:&format
                                                                     error:&error];
        if (!plist)
        {
            NSLog(@"%@", error.description);
            return nil;
        }

        fileTypes = [[NSMutableDictionary alloc] init];
        for (NSDictionary *item in plist)
        {
            NSUInteger type = [item[@"Type"] unsignedIntegerValue];
            NSUInteger aux = [item[@"Aux"] unsignedIntegerValue];
            NSNumber *key = @((type << 16) | aux);
            fileTypes[key] = [PDFileType fileTypeWithId:type name:item[@"Name"] detail:item[@"Definition"]];
        }

//        fileTypes[@0x00U] = [PDFileType fileTypeWithId:0x00
//                                            detail:@"Typeless file"];
//        fileTypes[@0x01U] = [PDFileType fileTypeWithId:0x01
//                                            detail:@"Bad block file"];
//        fileTypes[[NSNumber numberWithUnsignedInteger:TEXT_FILE_TYPE_ID]] = [PDFileType fileTypeWithId:TEXT_FILE_TYPE_ID
//                                                   name:@"TXT"
//                                            detail:@"ASCII text file"];
//        fileTypes[[NSNumber numberWithUnsignedInteger:BINARY_FILE_TYPE_ID]] = [PDFileType fileTypeWithId:BINARY_FILE_TYPE_ID
//                                                   name:@"BIN"
//                                            detail:@"General binary file"];
//        fileTypes[@0x08U] = [PDFileType fileTypeWithId:0x08
//                                            detail:@"Graphics screen file"];
//        fileTypes[[NSNumber numberWithUnsignedInteger:DIRECTORY_FILE_TYPE_ID]] = [PDFileType fileTypeWithId:DIRECTORY_FILE_TYPE_ID
//                                                   name:@"DIR"
//                                            detail:@"Directory file"];
//        fileTypes[@0x18U] = [PDFileType fileTypeWithId:0x18
//                                            detail:@"AppleWorks Data Base file"];
//        fileTypes[@0x19U] = [PDFileType fileTypeWithId:0x19
//                                            detail:@"AppleWorks Word Processor file"];
//        fileTypes[@0x1aU] = [PDFileType fileTypeWithId:0x1a
//                                            detail:@"AppleWorks Spreadsheet file"];
//        fileTypes[@0x1bU] = [PDFileType fileTypeWithId:0x1b
//                                            detail:@"AppleWorks Spreadsheet file"];
//        fileTypes[@0xb3U] = [PDFileType fileTypeWithId:0xb3
//                                                   name:@"S16"
//                                            detail:@"GS/OS application"];
//        fileTypes[@0xefU] = [PDFileType fileTypeWithId:0xef
//                                            detail:@"Pascal area"];
//        fileTypes[@0xf0U] = [PDFileType fileTypeWithId:0xf0
//                                            detail:@"ProDOS CI added command file"];
//        fileTypes[@0xf1U] = [PDFileType fileTypeWithId:0xf1
//                                            detail:@"ProDOS user defined file 1"];
//        fileTypes[@0xf2U] = [PDFileType fileTypeWithId:0xf2
//                                            detail:@"ProDOS user defined file 2"];
//        fileTypes[@0xf3U] = [PDFileType fileTypeWithId:0xf3
//                                            detail:@"ProDOS user defined file 3"];
//        fileTypes[@0xf4U] = [PDFileType fileTypeWithId:0xf4
//                                            detail:@"ProDOS user defined file 4"];
//        fileTypes[@0xf5U] = [PDFileType fileTypeWithId:0xf5
//                                            detail:@"ProDOS user defined file 5"];
//        fileTypes[@0xf6U] = [PDFileType fileTypeWithId:0xf6
//                                            detail:@"ProDOS user defined file 6"];
//        fileTypes[@0xf7U] = [PDFileType fileTypeWithId:0xf7
//                                            detail:@"ProDOS user defined file 7"];
//        fileTypes[@0xf8U] = [PDFileType fileTypeWithId:0xf8
//                                            detail:@"ProDOS user defined file 8"];
//        fileTypes[[NSNumber numberWithUnsignedInteger:INTEGER_BASIC_FILE_TYPE_ID]] = [PDFileType fileTypeWithId:INTEGER_BASIC_FILE_TYPE_ID
//                                            detail:@"Integer BASIC program file"];
//        fileTypes[@0xfbU] = [PDFileType fileTypeWithId:0xfb
//                                            detail:@"Integer BASIC variable file"];
//        fileTypes[[NSNumber numberWithUnsignedInteger:APPLESOFT_BASIC_FILE_TYPE_ID]] = [PDFileType fileTypeWithId:APPLESOFT_BASIC_FILE_TYPE_ID
//                                                   name:@"BAS"
//                                            detail:@"Applesoft program file"];
//        fileTypes[@0xfdU] = [PDFileType fileTypeWithId:0xfd
//                                                   name:@"VAR"
//                                            detail:@"Applesoft variables file"];
//        fileTypes[@0xfeU] = [PDFileType fileTypeWithId:0xfe
//                                                   name:@"REL"
//                                            detail:@"Relocatable code file (EDASM)"];
//        fileTypes[[NSNumber numberWithUnsignedInteger:SYSTEM_FILE_TYPE_ID]] = [PDFileType fileTypeWithId:SYSTEM_FILE_TYPE_ID
//                                                   name:@"SYS"
//                                            detail:@"ProDOS system file"];
    }
    return fileTypes;
}

+ (NSArray *)fileTypes
{
    // Build an array from the dictionary, including placeholders for the
    // missing entries
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:256];
    NSUInteger i;
    for (i = 0; i < 256; ++i)
        [array addObject:[PDFileType fileTypeWithId:i]];
    return array;
}

+ (PDFileType *)fileTypeWithId:(NSUInteger)aTypeId
{
    PDFileType *fileType = [PDFileType fileTypeDictionary][@(aTypeId << 16)];
    if (!fileType)
    {
        // Since we don't have a record of this type, create a placeholder
        fileType = [PDFileType fileTypeWithId:aTypeId detail:nil];
        fileTypes[@(aTypeId << 16)] = fileType;
    }
    return fileType;
}

+ (PDFileType *)fileTypeWithId:(NSUInteger)aTypeId
                          name:(NSString *)aName
                   detail:(NSString *)adetail;
{
    return [[PDFileType alloc] initWithId:aTypeId
                                      name:aName
                               detail:adetail];
}

+ (PDFileType *)fileTypeWithId:(NSUInteger)aTypeId
                   detail:(NSString *)adetail;
{
    return [[PDFileType alloc] initWithId:aTypeId
                               detail:adetail];
}

- (instancetype)initWithId:(NSUInteger)aTypeId
            name:(NSString *)aName
     detail:(NSString *)adetail;
{
    self = [super init];
    if (self)
    {
        typeId = aTypeId;
        name = [aName copy];
        detail = [adetail copy];
    }
    return self;
}

- (instancetype)initWithId:(NSUInteger)aTypeId
     detail:(NSString *)adetail;
{
    return [self initWithId:aTypeId
                       //name:[NSString stringWithFormat:@"$%02X", aTypeId]
                       name:nil
                     detail:adetail];
}


- (id)copyWithZone:(NSZone *)zone
{
    // File types are immutable, so just return ourself
    return self;
}

@synthesize typeId;
@synthesize name;
@synthesize detail;

- (NSString *)description
{
    if (name)
        return [NSString stringWithFormat:@"%@ ($%02lX)", name, (unsigned long)typeId];
    else
        return [NSString stringWithFormat:@"$%02lX", (unsigned long)typeId];
}

- (NSString *)nameOrTypeId
{
    if (name)
        return [NSString stringWithFormat:@"%@", name];
    else
        return [NSString stringWithFormat:@"$%02lX", (unsigned long)typeId];
}

@end
