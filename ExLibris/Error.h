//
//  Error.h
//  Ex Libris
//
//  Created by David Schweinsberg on 5/12/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import "ExLibrisErrors.h"
#import <Cocoa/Cocoa.h>

@interface Error : NSError

- (instancetype)initWithCode:(NSInteger)code;

+ (instancetype)errorWithCode:(NSInteger)code;

@end
