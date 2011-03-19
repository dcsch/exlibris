//
//  PDFileNameFormatter.h
//  Disk II
//
//  Created by David Schweinsberg on 3/03/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PDFileNameFormatter : NSFormatter
{
    NSCharacterSet *lettersCharSet;
    NSCharacterSet *legalCharSet;
}

@end
