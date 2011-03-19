//
//  Volume.m
//  Disk II
//
//  Created by David Schweinsberg on 25/10/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import "Volume.h"

@implementation Volume

- (id)initWithContainer:(NSObject *)aContainer
           blockStorage:(BlockStorage *)aBlockStorage
{
    self = [super init];
    if (self)
    {
        container = aContainer;
        blockStorage = aBlockStorage;
        [blockStorage retain];
    }
    return self;
}

- (void)dealloc
{
    [blockStorage release];
    [super dealloc];
}

- (NSScriptObjectSpecifier *)objectSpecifier
{
    NSScriptObjectSpecifier *containerSpec = container.objectSpecifier;
    return [[NSNameSpecifier alloc] initWithContainerClassDescription:containerSpec.keyClassDescription
                                                   containerSpecifier:containerSpec
                                                                  key:@"volume"
                                                                 name:self.name];
}

- (NSString *)name
{
    return nil;
}

@synthesize blockStorage;

@end
