//
//  ProDOSImage.m
//  Disk II
//
//  Created by David Schweinsberg on 1/01/08.
//  Copyright David Schweinsberg 2008. All rights reserved.
//

#import "ProDOSImage.h"
#import "BlockStorage.h"
#import "DiskII.h"
#import "DiskImageController.h"
#import "DiskImageHeader.h"
#import "ExLibrisErrors.h"
#import "PDFileEntry.h"
#import "PDFileType.h"
#import "PDVolume.h"
#import "ProDOSWindowController.h"

@interface ProDOSImage () {
  PDVolume *_volume;
  BlockStorage *_blockStorage;
}

@end

@implementation ProDOSImage

- (instancetype)init {
  self = [super init];
  if (self) {
  }
  return self;
}

- (void)makeWindowControllers {
  NSWindowController *controller = [[ProDOSWindowController alloc] init];
  [self addWindowController:controller];
}

- (BOOL)writeToURL:(NSURL *)absoluteURL
                 ofType:(NSString *)typeName
       forSaveOperation:(NSSaveOperationType)saveOperation
    originalContentsURL:(NSURL *)absoluteOriginalContentsURL
                  error:(NSError **)outError {
  NSLog(@"Saving %@", absoluteURL);

  //    if (saveOperation == NSSaveAsOperation)
  //    {
  //        [_blockStorage precacheBlocksInRange:NSMakeRange(0,
  //        self.blockCount)];
  //        self.fileURL = absoluteURL;
  //        _blockStorage.path = absoluteURL.path;
  //        [_blockStorage markModifiedBlocksInRange:NSMakeRange(0,
  //        self.blockCount)];
  //    }
  //    else if (saveOperation == NSAutosaveElsewhereOperation || saveOperation
  //    == NSAutosaveInPlaceOperation)
  //    {
  //        [_blockStorage precacheBlocksInRange:NSMakeRange(0,
  //        self.blockCount)];
  //        _blockStorage.path = absoluteURL.path;
  //        [_blockStorage markModifiedBlocksInRange:NSMakeRange(0,
  //        self.blockCount)];
  //    }

  [_blockStorage precacheBlocksInRange:NSMakeRange(0, self.blockCount)];
  [_blockStorage markModifiedBlocksInRange:NSMakeRange(0, self.blockCount)];
  _blockStorage.path = absoluteURL.path;

  if ([_blockStorage commitModifiedBlocks])
    return YES;

  if (outError)
    *outError = [NSError errorWithDomain:NSOSStatusErrorDomain
                                    code:unimpErr
                                userInfo:NULL];

  return NO;
}

- (BOOL)readFromURL:(NSURL *)absoluteURL
             ofType:(NSString *)typeName
              error:(NSError **)outError {
  NSFileManager *fileManager = [[NSFileManager alloc] init];
  NSDictionary *fileAttributes =
      [fileManager attributesOfItemAtPath:absoluteURL.path error:nil];
  self.blockCount = [fileAttributes fileSize] / kProDOSBlockSize;

  _blockStorage = [[BlockStorage alloc] initWithURL:absoluteURL];
  if (!_blockStorage)
    return NO;

  if ([DiskImageController extensionForUrl:absoluteURL] == EL2imgExtension) {
    NSData *headerData = [_blockStorage headerDataWithLength:256];
    DiskImageHeader *header = [[DiskImageHeader alloc] initWithData:headerData];
    if (header)
      _blockStorage.partitionOffset = header.imageDataOffset;
  }

  // Try handling this as a ProDOS image
  _volume =
      [[PDVolume alloc] initWithContainer:self blockStorage:_blockStorage];
  if (_volume)
    return YES;

  // TODO Work out why this information doesn't appear in the error alert
  if (outError) {
    NSMutableDictionary *errDict = [NSMutableDictionary dictionary];
    errDict[NSLocalizedDescriptionKey] =
        NSLocalizedString(@"UnrecognisedDiskImage", @"");
    *outError = [NSError errorWithDomain:ELErrorDomain
                                    code:ELBadProDOSImageError
                                userInfo:errDict];
  }
  return NO;
}

- (PDVolume *)volume {
  if (!_volume) {
    // TEMPORARY HACK
    if (self.blockCount == 0)
      self.blockCount = 280;
    // END TEMPORARY HACK

    // Lazy initialisation of a volume for new documents
    _blockStorage = [[BlockStorage alloc] initWithBlockSize:kProDOSBlockSize
                                                   capacity:self.blockCount];
    [PDVolume formatBlockStorage:_blockStorage];
    _volume =
        [[PDVolume alloc] initWithContainer:self blockStorage:_blockStorage];
  }
  return _volume;
}

- (void)setBlockCount:(NSUInteger)aBlockCount {
  // The block count can only be set if block storage isn't yet set up
  if (!_blockStorage)
    super.blockCount = aBlockCount;
}

- (void)insertEntry:(PDEntry *)entry {
  // Sort out the undo manager
  NSUndoManager *undo = self.undoManager;
  [[undo prepareWithInvocationTarget:self] deleteEntry:entry];
  if (!undo.undoing) {
    NSString *actionName =
        [NSString stringWithFormat:@"Insert %@", entry.fileName];
    [undo setActionName:actionName];
  }
}

- (void)deleteEntry:(PDEntry *)entry {
  // Sort out the undo manager
  NSUndoManager *undo = self.undoManager;
  [[undo prepareWithInvocationTarget:self] insertEntry:entry];
  if (!undo.undoing) {
    NSString *actionName =
        [NSString stringWithFormat:@"Delete %@", entry.fileName];
    [undo setActionName:actionName];
  }

  // Do the actual deletion
}

- (void)setFileName:(NSString *)aFileName ofEntry:(PDEntry *)anEntry {
  // Is anything changing?
  if ([anEntry.fileName isEqualToString:aFileName])
    return;

  // Sort out the undo manager
  NSUndoManager *undo = self.undoManager;
  [[undo prepareWithInvocationTarget:self] setFileName:anEntry.fileName
                                               ofEntry:anEntry];
  if (!undo.undoing) {
    NSString *actionName = [NSString
        stringWithFormat:@"Rename %@ to %@", anEntry.fileName, aFileName];
    [undo setActionName:actionName];
  }

  // Set the new name
  anEntry.fileName = aFileName;
}

- (void)setFileType:(NSUInteger)aTypeId ofEntry:(PDEntry *)anEntry {
  if (![anEntry isKindOfClass:[PDFileEntry class]])
    return;
  PDFileEntry *fileEntry = (PDFileEntry *)anEntry;

  // Is anything changing?
  if (fileEntry.fileType.typeId == aTypeId)
    return;

  //    // Sort out the undo manager
  //    NSUndoManager *undo = self.undoManager;
  //    [[undo prepareWithInvocationTarget:self] setFileType:fileEntry.fileType
  //                                                 ofEntry:fileEntry];
  //    if (![undo isUndoing])
  //        [undo setActionName:@"Change File Type"];
  //
  //    // Set the new file type
  //    fileEntry.fileType = aTypeId;

  //[self updateViews];
}

- (void)setAuxType:(NSUInteger)auxValue ofEntry:(PDEntry *)anEntry {
}

@end
