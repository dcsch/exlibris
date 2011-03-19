//
//  PDFileType.h
//  Disk II
//
//  Created by David Schweinsberg on 9/02/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define TEXT_FILE_TYPE_ID               0x04
#define BINARY_FILE_TYPE_ID             0x06
#define DIRECTORY_FILE_TYPE_ID          0x0f
#define INTEGER_BASIC_FILE_TYPE_ID      0xfa
#define APPLESOFT_BASIC_FILE_TYPE_ID    0xfc
#define SYSTEM_FILE_TYPE_ID             0xff

@interface PDFileType : NSObject <NSCopying>
{
    NSUInteger typeId;
    NSString *name;
    NSString *detail;
}

@property(readonly) NSUInteger typeId;
@property(copy, readonly) NSString *name;
@property(copy, readonly) NSString *detail;
@property(copy, readonly) NSString *nameOrTypeId;

+ (NSDictionary *)fileTypeDictionary;

+ (NSArray *)fileTypes;

+ (PDFileType *)fileTypeWithId:(NSUInteger)aTypeId;

+ (PDFileType *)fileTypeWithId:(NSUInteger)aTypeId
                          name:(NSString *)aName
                        detail:(NSString *)aDescription;

+ (PDFileType *)fileTypeWithId:(NSUInteger)aTypeId
                        detail:(NSString *)aDescription;

- (id)initWithId:(NSUInteger)aTypeId
            name:(NSString *)aName
          detail:(NSString *)aDescription;

- (id)initWithId:(NSUInteger)aTypeId
          detail:(NSString *)aDescription;

@end
