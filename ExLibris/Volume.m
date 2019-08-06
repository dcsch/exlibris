//
//  Volume.m
//  Disk II
//
//  Created by David Schweinsberg on 25/10/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import "Volume.h"
#import "BlockStorage.h"

@implementation Volume

- (instancetype)initWithContainer:(NSObject *)aContainer
                     blockStorage:(BlockStorage *)aBlockStorage {
  self = [super init];
  if (self) {
    container = aContainer;
    blockStorage = aBlockStorage;
  }
  return self;
}

- (NSScriptObjectSpecifier *)objectSpecifier {
  NSScriptObjectSpecifier *containerSpec = container.objectSpecifier;
  return [[NSNameSpecifier alloc]
      initWithContainerClassDescription:containerSpec.keyClassDescription
                     containerSpecifier:containerSpec
                                    key:@"volume"
                                   name:self.name];
}

- (NSString *)name {
  return nil;
}

@synthesize blockStorage;

@end
