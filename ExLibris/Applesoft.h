//
//  Applesoft.h
//  Disk II
//
//  Created by David Schweinsberg on 13/01/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Applesoft : NSObject
{

}

+ (NSString *)keywordForToken:(unsigned int)token;
+ (NSString *)parseData:(NSData *)data hasHeader:(BOOL)aHeader;

@end
