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
        fileTypes = [[NSMutableDictionary alloc] init];
        [fileTypes setObject:[PDFileType fileTypeWithId:0x00
                                            detail:@"Typeless file"]
                      forKey:[NSNumber numberWithUnsignedInt:0x00]];
        [fileTypes setObject:[PDFileType fileTypeWithId:0x01
                                            detail:@"Bad block file"]
                      forKey:[NSNumber numberWithUnsignedInt:0x01]];
        [fileTypes setObject:[PDFileType fileTypeWithId:TEXT_FILE_TYPE_ID
                                                   name:@"TXT"
                                            detail:@"ASCII text file"]
                      forKey:[NSNumber numberWithUnsignedInt:TEXT_FILE_TYPE_ID]];
        [fileTypes setObject:[PDFileType fileTypeWithId:BINARY_FILE_TYPE_ID
                                                   name:@"BIN"
                                            detail:@"General binary file"]
                      forKey:[NSNumber numberWithUnsignedInt:BINARY_FILE_TYPE_ID]];
        [fileTypes setObject:[PDFileType fileTypeWithId:0x08
                                            detail:@"Graphics screen file"]
                      forKey:[NSNumber numberWithUnsignedInt:0x08]];
        [fileTypes setObject:[PDFileType fileTypeWithId:DIRECTORY_FILE_TYPE_ID
                                                   name:@"DIR"
                                            detail:@"Directory file"]
                      forKey:[NSNumber numberWithUnsignedInt:DIRECTORY_FILE_TYPE_ID]];
        [fileTypes setObject:[PDFileType fileTypeWithId:0x18
                                            detail:@"AppleWorks Data Base file"]
                      forKey:[NSNumber numberWithUnsignedInt:0x18]];
        [fileTypes setObject:[PDFileType fileTypeWithId:0x19
                                            detail:@"AppleWorks Word Processor file"]
                      forKey:[NSNumber numberWithUnsignedInt:0x19]];
        [fileTypes setObject:[PDFileType fileTypeWithId:0x1a
                                            detail:@"AppleWorks Spreadsheet file"]
                      forKey:[NSNumber numberWithUnsignedInt:0x1a]];
        [fileTypes setObject:[PDFileType fileTypeWithId:0x1b
                                            detail:@"AppleWorks Spreadsheet file"]
                      forKey:[NSNumber numberWithUnsignedInt:0x1b]];
        [fileTypes setObject:[PDFileType fileTypeWithId:0xb3
                                                   name:@"S16"
                                            detail:@"GS/OS application"]
                      forKey:[NSNumber numberWithUnsignedInt:0xb3]];
        [fileTypes setObject:[PDFileType fileTypeWithId:0xef
                                            detail:@"Pascal area"]
                      forKey:[NSNumber numberWithUnsignedInt:0xef]];
        [fileTypes setObject:[PDFileType fileTypeWithId:0xf0
                                            detail:@"ProDOS CI added command file"]
                      forKey:[NSNumber numberWithUnsignedInt:0xf0]];
        [fileTypes setObject:[PDFileType fileTypeWithId:0xf1
                                            detail:@"ProDOS user defined file 1"]
                      forKey:[NSNumber numberWithUnsignedInt:0xf1]];
        [fileTypes setObject:[PDFileType fileTypeWithId:0xf2
                                            detail:@"ProDOS user defined file 2"]
                      forKey:[NSNumber numberWithUnsignedInt:0xf2]];
        [fileTypes setObject:[PDFileType fileTypeWithId:0xf3
                                            detail:@"ProDOS user defined file 3"]
                      forKey:[NSNumber numberWithUnsignedInt:0xf3]];
        [fileTypes setObject:[PDFileType fileTypeWithId:0xf4
                                            detail:@"ProDOS user defined file 4"]
                      forKey:[NSNumber numberWithUnsignedInt:0xf4]];
        [fileTypes setObject:[PDFileType fileTypeWithId:0xf5
                                            detail:@"ProDOS user defined file 5"]
                      forKey:[NSNumber numberWithUnsignedInt:0xf5]];
        [fileTypes setObject:[PDFileType fileTypeWithId:0xf6
                                            detail:@"ProDOS user defined file 6"]
                      forKey:[NSNumber numberWithUnsignedInt:0xf6]];
        [fileTypes setObject:[PDFileType fileTypeWithId:0xf7
                                            detail:@"ProDOS user defined file 7"]
                      forKey:[NSNumber numberWithUnsignedInt:0xf7]];
        [fileTypes setObject:[PDFileType fileTypeWithId:0xf8
                                            detail:@"ProDOS user defined file 8"]
                      forKey:[NSNumber numberWithUnsignedInt:0xf8]];
        [fileTypes setObject:[PDFileType fileTypeWithId:INTEGER_BASIC_FILE_TYPE_ID
                                            detail:@"Integer BASIC program file"]
                      forKey:[NSNumber numberWithUnsignedInt:INTEGER_BASIC_FILE_TYPE_ID]];
        [fileTypes setObject:[PDFileType fileTypeWithId:0xfb
                                            detail:@"Integer BASIC variable file"]
                      forKey:[NSNumber numberWithUnsignedInt:0xfb]];
        [fileTypes setObject:[PDFileType fileTypeWithId:APPLESOFT_BASIC_FILE_TYPE_ID
                                                   name:@"BAS"
                                            detail:@"Applesoft program file"]
                      forKey:[NSNumber numberWithUnsignedInt:APPLESOFT_BASIC_FILE_TYPE_ID]];
        [fileTypes setObject:[PDFileType fileTypeWithId:0xfd
                                                   name:@"VAR"
                                            detail:@"Applesoft variables file"]
                      forKey:[NSNumber numberWithUnsignedInt:0xfd]];
        [fileTypes setObject:[PDFileType fileTypeWithId:0xfe
                                                   name:@"REL"
                                            detail:@"Relocatable code file (EDASM)"]
                      forKey:[NSNumber numberWithUnsignedInt:0xfe]];
        [fileTypes setObject:[PDFileType fileTypeWithId:SYSTEM_FILE_TYPE_ID
                                                   name:@"SYS"
                                            detail:@"ProDOS system file"]
                      forKey:[NSNumber numberWithUnsignedInt:SYSTEM_FILE_TYPE_ID]];
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
    PDFileType *fileType = [[PDFileType fileTypeDictionary] objectForKey:
                            [NSNumber numberWithUnsignedInt:aTypeId]];
    if (!fileType)
    {
        // Since we don't have a record of this type, create a placeholder
        fileType = [PDFileType fileTypeWithId:aTypeId detail:nil];
        [fileTypes setObject:fileType
                      forKey:[NSNumber numberWithUnsignedInt:aTypeId]];
    }
    return fileType;
}

+ (PDFileType *)fileTypeWithId:(NSUInteger)aTypeId
                          name:(NSString *)aName
                   detail:(NSString *)adetail;
{
    return [[[PDFileType alloc] initWithId:aTypeId
                                      name:aName
                               detail:adetail] autorelease];
}

+ (PDFileType *)fileTypeWithId:(NSUInteger)aTypeId
                   detail:(NSString *)adetail;
{
    return [[[PDFileType alloc] initWithId:aTypeId
                               detail:adetail] autorelease];
}

- (id)initWithId:(NSUInteger)aTypeId
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

- (id)initWithId:(NSUInteger)aTypeId
     detail:(NSString *)adetail;
{
    return [self initWithId:aTypeId
                       //name:[NSString stringWithFormat:@"$%02X", aTypeId]
                       name:nil
                     detail:adetail];
}

- (void)dealloc
{
    [name release];
    [detail release];
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
    // File types are immutable, so just return ourself
    return [self retain];
}

@synthesize typeId;
@synthesize name;
@synthesize detail;

- (NSString *)description
{
    if (name)
        return [NSString stringWithFormat:@"%@ ($%02X)", name, typeId];
    else
        return [NSString stringWithFormat:@"$%02X", typeId];
}

- (NSString *)nameOrTypeId
{
    if (name)
        return [NSString stringWithFormat:@"%@", name];
    else
        return [NSString stringWithFormat:@"$%02X", typeId];
}

@end
