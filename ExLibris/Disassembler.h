//
//  Disassembler.h
//  Disk II
//
//  Created by David Schweinsberg on 14/01/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Disassembler : NSObject
{

}

+ (NSString *)disassembleData:(NSData *)data
                   withOffset:(unsigned int)offset
                    hasHeader:(BOOL)aHeader;

@end
