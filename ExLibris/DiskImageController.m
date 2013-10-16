//
//  DiskImageController.m
//  Ex Libris
//
//  Created by David Schweinsberg on 18/12/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import "DiskImageController.h"
#import "BlockStorage.h"
#import "PDVolume.h"
#import "D3Volume.h"
#import "DiskImageHeader.h"
#import "NewDiskImageController.h"
#import "DiskII.h"

@interface DiskImageController ()
{
    NSWindowController *_newDiskImageController;
}

@end


@implementation DiskImageController

- (NSString *)typeForContentsOfURL:(NSURL *)inAbsoluteURL error:(NSError **)outError
{
    // If the file extension is an ambiguous type (such as .dsk) or there is a
    // file header that describes the type (such as 2img), then find out what
    // the file type is.  Otherwise pass it on to the default document handler
    ELDiskImageExtension ext = [DiskImageController extensionForUrl:inAbsoluteURL];
    NSUInteger offset = 0;
    BOOL sniff = NO;

    if (ext == EL2imgExtension)
    {
        BlockStorage *blockStorage = [[BlockStorage alloc] initWithURL:inAbsoluteURL];
        NSData *headerData = [blockStorage headerDataWithLength:256];
        DiskImageHeader *header = [[DiskImageHeader alloc] initWithData:headerData];
        if (header)
        {
            offset = header.imageDataOffset;
        }
        sniff = YES;
    }
                
    if (ext == ELDskExtension || sniff)
    {
        NSString *docType = nil;

        // We need to sniff out the file type
        BlockStorage *blockStorage = [[BlockStorage alloc] initWithURL:inAbsoluteURL];
        if (blockStorage)
        {
            if (offset > 0)
                blockStorage.partitionOffset = offset;

            // Try handling this as a ProDOS image
            Volume *volume = [[PDVolume alloc] initWithContainer:self blockStorage:blockStorage];
            if (volume)
            {
                docType = ELAppleProDOSDiskImageDocumentType;
            }
            else
            {
                // Try handling this as a DOS 3.x image
                volume = [[D3Volume alloc] initWithContainer:self blockStorage:blockStorage];
                if (volume)
                    docType = ELAppleDOS33DiskImageDocumentType;
            }
        }
        
        return docType;
    }
    
    return [super typeForContentsOfURL:inAbsoluteURL error:outError];
}

- (id)makeUntitledDocumentOfType:(NSString *)typeName error:(NSError **)outError
{
    return [super makeUntitledDocumentOfType:typeName error:outError];
}

- (IBAction)newDocument:(id)sender
{
    if (!_newDiskImageController)
        _newDiskImageController = [[NewDiskImageController alloc] init];
    [_newDiskImageController showWindow:self];
//    return [super newDocument:sender];
}

+ (ELDiskImageExtension)extensionForUrl:(NSURL *)url
{
    NSString *path = [url absoluteString];
    NSString *ext = [path pathExtension];
    
    if ([ext caseInsensitiveCompare:@"2mg"] == 0
        || [ext caseInsensitiveCompare:@"2img"] == 0)
        return EL2imgExtension;
    else if ([ext caseInsensitiveCompare:@"dsk"] == 0)
        return ELDskExtension;
    else
        return ELUnknownExtension;
}

@end
