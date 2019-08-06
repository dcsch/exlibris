/*
 *  ExLibrisErrors.h
 *  Ex Libris
 *
 *  Created by David Schweinsberg on 5/12/08.
 *  Copyright 2008 David Schweinsberg. All rights reserved.
 *
 */

extern NSString *ELErrorDomain;

// Error codes

enum {
  ELBadProDOSImageError = 1,
  ELBadDOS3xImageError,
  ELVolumeDirectoryEntryLimitError,
  ELVolumeSpaceLimitError
};
