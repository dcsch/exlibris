//
//  main.m
//  ExLibris
//
//  Created by David Schweinsberg on 19/03/11.
//  Copyright 2011 Synchroma Pty Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DiskII.h"

const NSUInteger kProDOSBlockSize = 512;

NSString *ELErrorDomain = @"org.synchroma.exlibris.ErrorDomain";

NSString *ProDOSFilePboardType = @"org.synchroma.ProDOSFileContentWithMetadata";
NSString *DOS33FilePboardType = @"org.synchroma.DOS33FileContentWithMetadata";

NSString *ELAppleProDOSDiskImageDocumentType = @"Apple II Disk Image (ProDOS)";
NSString *ELAppleDOS33DiskImageDocumentType  = @"Apple II Disk Image (DOS)";

// User defaults

NSString *ShowAllDirectoryEntriesKey = @"ELShowAllDirectoryEntries";

// Notifications

NSString *ShowAllDirectoryEntriesChanged = @"ELShowAllDirectoryEntriesChanged";

// Functions

unsigned short unpackWord(const unsigned char *data)
{
    return (data[1] << 8) | data[0];
}

void packWord(unsigned char *data, unsigned short value)
{
    data[0] = (unsigned char) value;
    data[1] = (unsigned char)(value >> 8);
}

int main(int argc, char *argv[])
{
    return NSApplicationMain(argc, (const char **)argv);
}
