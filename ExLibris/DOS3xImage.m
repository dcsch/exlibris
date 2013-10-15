//
//  DOS3xImage.m
//  Disk II
//
//  Created by David Schweinsberg on 1/01/08.
//  Copyright David Schweinsberg 2008. All rights reserved.
//

#import "DOS3xImage.h"
#import "DOS3xWindowController.h"
#import "DiskImageHeader.h"
#import "D3Volume.h"
#import "BlockStorage.h"
#import "DiskImageController.h"
#import "DiskII.h"
#import "ExLibrisErrors.h"

@interface DOS3xImage ()
{
    D3Volume *_volume;
    BlockStorage *_blockStorage;
}

@end


@implementation DOS3xImage

- (id)init
{
    self = [super init];
    if (self)
    {
    }
    return self;
}


- (void)makeWindowControllers
{
    NSWindowController *controller = [[DOS3xWindowController alloc] init];
    [self addWindowController:controller];
}

- (BOOL)saveToURL:(NSURL *)absoluteURL
           ofType:(NSString *)typeName
 forSaveOperation:(NSSaveOperationType)saveOperation
            error:(NSError **)outError
{
    NSLog(@"Saving %@", absoluteURL);
    
    if (saveOperation == NSSaveAsOperation)
    {
//        // Copy the current block storage to a new block storage
//        BlockStorage *blockStorage2 = [[BlockStorage alloc] initWithURL:absoluteURL
//                                                           blockStorage:volume.blockStorage];
//        [blockStorage2 release];
    }
    
    if ([_blockStorage commitModifiedBlocks])
        return YES;

    *outError = [NSError errorWithDomain:NSOSStatusErrorDomain
                                    code:unimpErr
                                userInfo:NULL];
    
    return NO;
}

- (BOOL)readFromURL:(NSURL *)absoluteURL
             ofType:(NSString *)typeName
              error:(NSError **)outError
{
    _blockStorage = [[BlockStorage alloc] initWithURL:absoluteURL];
    if (!_blockStorage)
        return NO;
    
    if ([DiskImageController extensionForUrl:absoluteURL] == EL2imgExtension)
    {
        NSData *headerData = [_blockStorage headerDataWithLength:256];
        DiskImageHeader *header = [[DiskImageHeader alloc] initWithData:headerData];
        if (header)
            _blockStorage.partitionOffset = header.imageDataOffset;
    }
    
    // Try handling this as a DOS 3.x image
    _volume = [[D3Volume alloc] initWithContainer:self blockStorage:_blockStorage];
    if (_volume)
        return YES;
    
    // TODO Work out why this information doesn't appear in the error alert
    NSMutableDictionary *errDict = [NSMutableDictionary dictionary];
    errDict[NSLocalizedDescriptionKey] = NSLocalizedString(@"UnrecognisedDiskImage", @"");
    *outError = [NSError errorWithDomain:ELErrorDomain
                                    code:ELBadDOS3xImageError
                                userInfo:errDict];
    return NO;
}

//- (void)insertEntry:(PDEntry *)entry
//{
//    // Sort out the undo manager
//    NSUndoManager *undo = self.undoManager;
//    [[undo prepareWithInvocationTarget:self] deleteEntry:entry];
//    if (![undo isUndoing])
//    {
//        NSString *actionName = [NSString stringWithFormat:@"Insert %@",
//                                entry.fileName];
//        [undo setActionName:actionName];
//    }
//}
//
//- (void)deleteEntry:(PDEntry *)entry
//{
//    // Sort out the undo manager
//    NSUndoManager *undo = self.undoManager;
//    [[undo prepareWithInvocationTarget:self] insertEntry:entry];
//    if (![undo isUndoing])
//    {
//        NSString *actionName = [NSString stringWithFormat:@"Delete %@",
//                                entry.fileName];
//        [undo setActionName:actionName];
//    }
//    
//    // Do the actual deletion
//}
//
//- (void)setFileName:(NSString *)aFileName ofEntry:(PDEntry *)anEntry
//{
//    // Is anything changing?
//    if ([anEntry.fileName isEqualToString:aFileName])
//        return;
//
//    // Sort out the undo manager
//    NSUndoManager *undo = self.undoManager;
//    [[undo prepareWithInvocationTarget:self] setFileName:anEntry.fileName
//                                                 ofEntry:anEntry];
//    if (![undo isUndoing])
//    {
//        NSString *actionName = [NSString stringWithFormat:@"Rename %@ to %@",
//                                anEntry.fileName,
//                                aFileName];
//        [undo setActionName:actionName];
//    }
//    
//    // Set the new name
//    anEntry.fileName = aFileName;
//}
//
//- (void)setFileType:(NSUInteger)aTypeId ofEntry:(PDEntry *)anEntry
//{
//    if (![anEntry isKindOfClass:[PDFileEntry class]])
//        return;
//    PDFileEntry *fileEntry = (PDFileEntry *)anEntry;
//
//    // Is anything changing?
//    if (fileEntry.fileType.typeId == aTypeId)
//        return;
//
////    // Sort out the undo manager
////    NSUndoManager *undo = self.undoManager;
////    [[undo prepareWithInvocationTarget:self] setFileType:fileEntry.fileType
////                                                 ofEntry:fileEntry];
////    if (![undo isUndoing])
////        [undo setActionName:@"Change File Type"];
////
////    // Set the new file type
////    fileEntry.fileType = aTypeId;
//    
//    //[self updateViews];
//}

@end
