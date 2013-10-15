//
//  DOS3xImage.h
//  Disk II
//
//  Created by David Schweinsberg on 1/01/08.
//  Copyright David Schweinsberg 2008 . All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import "DiskImage.h"

@class D3Volume;

@interface DOS3xImage : DiskImage

@property(strong, readonly) D3Volume *volume;

//- (void)insertEntry:(PDEntry *)entry;
//
//- (void)deleteEntry:(PDEntry *)entry;
//
//- (void)setFileName:(NSString *)aFileName ofEntry:(PDEntry *)anEntry;

//- (void)setFileType:(NSUInteger)aTypeId ofEntry:(PDEntry *)anEntry;

@end
