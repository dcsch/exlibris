//
//  DiskImage.m
//  Disk II
//
//  Created by David Schweinsberg on 1/01/08.
//  Copyright David Schweinsberg 2008. All rights reserved.
//

#import "DiskImage.h"

@implementation DiskImage

+ (BOOL)autosavesInPlace {
  return YES;
}

- (instancetype)init {
  self = [super init];
  if (self) {
  }
  return self;
}

@end
