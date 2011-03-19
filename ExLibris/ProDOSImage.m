//
//  ProDOSImage.m
//  Disk II
//
//  Created by David Schweinsberg on 1/01/08.
//  Copyright David Schweinsberg 2008. All rights reserved.
//

#import "ProDOSImage.h"
#import "ProDOSWindowController.h"
#import "DiskImageHeader.h"
#import "PDVolume.h"
#import "PDFileEntry.h"
#import "PDFileType.h"
#import "BlockStorage.h"
#import "DiskImageController.h"
#import "DiskII.h"
#import "ExLibrisErrors.h"

@implementation ProDOSImage

- (id)init
{
    self = [super init];
    if (self)
    {
    }
    return self;
}

- (void)dealloc
{
    [volume release];
    [blockStorage release];
    [super dealloc];
}

- (void)makeWindowControllers
{
    NSWindowController *controller = [[ProDOSWindowController alloc] init];
    [self addWindowController:controller];
    [controller release];
}

- (BOOL)saveToURL:(NSURL *)absoluteURL
           ofType:(NSString *)typeName
 forSaveOperation:(NSSaveOperationType)saveOperation
            error:(NSError **)outError
{
    NSLog(@"Saving %@", absoluteURL);
    
    if (saveOperation == NSSaveAsOperation)
    {
        // TODO mark all blocks as modified and needing to be written out

        self.fileURL = absoluteURL;
        blockStorage.path = absoluteURL.path;
    }
    
    if ([blockStorage commitModifiedBlocks])
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
    blockStorage = [[BlockStorage alloc] initWithURL:absoluteURL];
    if (!blockStorage)
        return NO;
    
    if ([DiskImageController extensionForUrl:absoluteURL] == EL2imgExtension)
    {
        NSData *headerData = [blockStorage headerDataWithLength:256];
        DiskImageHeader *header = [[DiskImageHeader alloc] initWithData:headerData];
        if (header)
            blockStorage.partitionOffset = header.imageDataOffset;
        [header release];
    }
    
    // Try handling this as a ProDOS image
    volume = [[PDVolume alloc] initWithContainer:self blockStorage:blockStorage];
    if (volume)
        return YES;
    
    // TODO Work out why this information doesn't appear in the error alert
    NSMutableDictionary *errDict = [NSMutableDictionary dictionary];
    [errDict setObject:NSLocalizedString(@"UnrecognisedDiskImage", @"")
                forKey:NSLocalizedDescriptionKey];
    *outError = [NSError errorWithDomain:ELErrorDomain
                                    code:ELBadProDOSImageError
                                userInfo:errDict];
    return NO;
}

- (PDVolume *)volume
{
    if (!volume)
    {
        // Lazy initialisation of a volume for new documents
        blockStorage = [[BlockStorage alloc] initWithBlockSize:kProDOSBlockSize
                                                      capacity:self.blockCount];
        [PDVolume formatBlockStorage:blockStorage];
        volume = [[PDVolume alloc] initWithContainer:self blockStorage:blockStorage];
    }
    return volume;
}

- (NSUInteger)blockCount
{
    return blockCount;
}

- (void)setBlockCount:(NSUInteger)aBlockCount
{
    // The block count can only be set if block storage isn't yet set up
    if (!blockStorage)
        blockCount = aBlockCount;
}

- (void)insertEntry:(PDEntry *)entry
{
    // Sort out the undo manager
    NSUndoManager *undo = self.undoManager;
    [[undo prepareWithInvocationTarget:self] deleteEntry:entry];
    if (![undo isUndoing])
    {
        NSString *actionName = [NSString stringWithFormat:@"Insert %@",
                                entry.fileName];
        [undo setActionName:actionName];
    }
}

- (void)deleteEntry:(PDEntry *)entry
{
    // Sort out the undo manager
    NSUndoManager *undo = self.undoManager;
    [[undo prepareWithInvocationTarget:self] insertEntry:entry];
    if (![undo isUndoing])
    {
        NSString *actionName = [NSString stringWithFormat:@"Delete %@",
                                entry.fileName];
        [undo setActionName:actionName];
    }
    
    // Do the actual deletion
}

- (void)setFileName:(NSString *)aFileName ofEntry:(PDEntry *)anEntry
{
    // Is anything changing?
    if ([anEntry.fileName isEqualToString:aFileName])
        return;

    // Sort out the undo manager
    NSUndoManager *undo = self.undoManager;
    [[undo prepareWithInvocationTarget:self] setFileName:anEntry.fileName
                                                 ofEntry:anEntry];
    if (![undo isUndoing])
    {
        NSString *actionName = [NSString stringWithFormat:@"Rename %@ to %@",
                                anEntry.fileName,
                                aFileName];
        [undo setActionName:actionName];
    }
    
    // Set the new name
    anEntry.fileName = aFileName;
}

- (void)setFileType:(NSUInteger)aTypeId ofEntry:(PDEntry *)anEntry
{
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

- (void)setAuxType:(NSUInteger)auxValue ofEntry:(PDEntry *)anEntry
{
}

@end
