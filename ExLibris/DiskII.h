/*
 *  DiskII.h
 *  Disk II
 *
 *  Created by David Schweinsberg on 12/08/08.
 *  Copyright 2008 David Schweinsberg. All rights reserved.
 *
 */

extern const NSUInteger kProDOSBlockSize;

extern NSString *ProDOSFilePboardType;
extern NSString *DOS33FilePboardType;

extern NSString *ELAppleProDOSDiskImageDocumentType;
extern NSString *ELAppleDOS33DiskImageDocumentType;

// User defaults

extern NSString *ShowAllDirectoryEntriesKey;

// Notifications

extern NSString *ShowAllDirectoryEntriesChanged;

// Functions

unsigned short unpackWord(const unsigned char *data);

void packWord(unsigned char *data, unsigned short value);
