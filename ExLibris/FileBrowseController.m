//
//  FileBrowseController.m
//  Disk II
//
//  Created by David Schweinsberg on 10/01/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import "FileBrowseController.h"
#import "PDFileType.h"
#import "Applesoft.h"
#import "Disassembler.h"
#import "ProDOSImage.h"
#import "PDVolume.h"
#import "PDEntry.h"
#import "DiskII.h"

@implementation FileBrowseController

- (instancetype)initWithData:(NSData *)aData
      startAddress:(NSUInteger)aStartAddress
              name:(NSString *)aName
            typeId:(NSUInteger)aTypeId
         hasHeader:(BOOL)aHeader
{
    self = [super initWithWindowNibName:@"FileBrowse"];
    if (self)
    {
        name = [aName copy];
        typeId = aTypeId;
        header = aHeader;
        data = aData;
        startAddress = aStartAddress;
    }
    return self;
}


- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName
{
    NSMutableString *ms = [[NSMutableString alloc] initWithString:name];
    [ms appendFormat:@" (%@)", displayName];
    return ms;
}

- (void)windowDidLoad
{
    if (!data)
    {
        textView.string = @"Unhandled storage type";
        return;
    }

    // Set the available display formats
    NSMenuItem *menuItem = [popUpButton itemWithTitle:@"Hex Dump"];
    [menuItem setHidden:NO];
    if (typeId == APPLESOFT_BASIC_FILE_TYPE_ID)
    {
        menuItem = [popUpButton itemWithTitle:@"Applesoft BASIC"];
        [menuItem setHidden:NO];
        [self displayApplesoftBasic:self];
    }
    else if (typeId == BINARY_FILE_TYPE_ID
             || typeId == SYSTEM_FILE_TYPE_ID)
    {
        menuItem = [popUpButton itemWithTitle:@"6502 Disassembly"];
        [menuItem setHidden:NO];
        [self display6502Disassembly:self];
    }
    else if (typeId == TEXT_FILE_TYPE_ID)
    {
        menuItem = [popUpButton itemWithTitle:@"Text"];
        [menuItem setHidden:NO];
        [self displayText:self];
    }
    else if (typeId == DIRECTORY_FILE_TYPE_ID)
    {
        menuItem = [popUpButton itemWithTitle:@"ProDOS Catalog"];
        [menuItem setHidden:NO];
        [self displayCatalog:self];
    }
    else
        [self displayHexDump:self];
        
    [popUpButton selectItem:menuItem];

    textView.font = [NSFont userFixedPitchFontOfSize:10];
}

- (void)hexDump
{
    NSUInteger length;
//    if ([entry isKindOfClass:[PDFileEntry class]])
//        length = [(PDFileEntry *)entry eof];
//    else
        length = data.length;
            
    NSMutableString *hexDumpString = [NSMutableString string];
    NSUInteger lineCount = length / 16;
    NSUInteger line;
    for (line = 0; line < lineCount; ++line)
    {
        const unsigned char *ptr = data.bytes + 16 * line;
        [hexDumpString appendFormat:@"%08lx: ", 16 * line];
        [hexDumpString appendFormat:@"%02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x  ",
            ptr[0],
            ptr[1],
            ptr[2],
            ptr[3],
            ptr[4],
            ptr[5],
            ptr[6],
            ptr[7],
            ptr[8],
            ptr[9],
            ptr[10],
            ptr[11],
            ptr[12],
            ptr[13],
            ptr[14],
            ptr[15]];
        
        // Convert values into printable ASCII codes, mirroring the standard
        // set in the 128-255 range
        char c[16];
        int i;
        for (i = 0; i < 16; ++i)
        {
            if (32 <= ptr[i] && ptr[i] <= 127)
                c[i] = ptr[i];
            else if (160 <= ptr[i] && ptr[i] <= 255)
                c[i] = ptr[i] - 128;
            else
                c[i] = '.';
        }
        [hexDumpString appendFormat:@"%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c\n",
            c[0],
            c[1],
            c[2],
            c[3],
            c[4],
            c[5],
            c[6],
            c[7],
            c[8],
            c[9],
            c[10],
            c[11],
            c[12],
            c[13],
            c[14],
            c[15]];
    }
    
    // Do we have a few stray bytes?
    unsigned int extraBytes = length % 16;
    if (extraBytes)
    {
        const unsigned char *ptr = data.bytes + 16 * lineCount;
        [hexDumpString appendFormat:@"%08lx: ", 16 * lineCount];
        unsigned int i;
        for (i = 0; i < extraBytes; ++i)
            [hexDumpString appendFormat:@"%02x ", ptr[i]];
        for (i = 0; i < 16 - extraBytes; ++i)
            [hexDumpString appendString:@"   "];
        
        char c[16];
        for (i = 0; i < 16; ++i)
        {
            if (i < extraBytes)
            {
                if (32 <= ptr[i] && ptr[i] <= 127)
                    c[i] = ptr[i];
                else if (160 <= ptr[i] && ptr[i] <= 255)
                    c[i] = ptr[i] - 128;
                else
                    c[i] = '.';
            }
            else c[i] = ' ';
        }
        [hexDumpString appendFormat:@" %c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c\n",
            c[0],
            c[1],
            c[2],
            c[3],
            c[4],
            c[5],
            c[6],
            c[7],
            c[8],
            c[9],
            c[10],
            c[11],
            c[12],
            c[13],
            c[14],
            c[15]];
    }

    textView.string = hexDumpString;
}

- (void)catalog
{
    // Parse the directory data independently of the PDDirectoryBlock code

    NSMutableString *catString = [NSMutableString string];
    const unsigned char *ptr = data.bytes;

    // This this the right data?
    unsigned char storageType = ptr[0x04] >> 4;
    if (storageType != 15 && storageType != 14)
    {
        textView.string = @"Invalid directory data";
        return;
    }
    
    unsigned char entryLength = ptr[0x23];
    unsigned char entriesPerBlock = ptr[0x24];
    
    // Get the directory name, and display all data in BI 'CATALOG' format
    unsigned char nameLen = ptr[0x04] & 0xf;
    NSString *dirName = [[NSString alloc] initWithBytes:ptr + 0x05
                                           length:nameLen
                                         encoding:[NSString defaultCStringEncoding]];
    if (storageType == 15)
        [catString appendString:@"/"];
    [catString appendFormat:@"%@\n\n", dirName];

    [catString appendString:@" NAME           TYPE  BLOCKS  MODIFIED         CREATED          ENDFILE SUBTYPE\n\n"];
    
    // Iterate through each of the directory entries in each of the blocks
    unsigned char index = 1;
    NSUInteger blockIndex = 0;
    ptr += entryLength + 4;
    
    do
    {
        for ( ; index < entriesPerBlock; ++index, ptr += entryLength)
        {
            storageType = ptr[0x00] >> 4;
            if (storageType == 0)
                continue;

            // Get the file name
            nameLen = ptr[0x00] & 0xf;
            dirName = [[NSString alloc] initWithBytes:ptr + 0x01
                                               length:nameLen
                                             encoding:[NSString defaultCStringEncoding]];
            BOOL locked = (ptr[0x1e] & 0x02) ? NO : YES;
            char *spc = "               ";
            [catString appendFormat:@"%c%@%s ", locked ? '*' : ' ', dirName, spc + nameLen];
            
            // File type
            PDFileType *fileType = [PDFileType fileTypeWithId:ptr[0x10]];
            [catString appendFormat:@"%@ ", fileType.nameOrTypeId];
            
            // Blocks used
            [catString appendFormat:@"  %5d ", unpackWord(ptr + 0x13)];
            
            // Modified
            NSInteger year;
            NSInteger month;
            NSInteger day;
            NSInteger hour;
            NSInteger minute;
            char *nameOfMonth = "JAN\0FEB\0MAR\0APR\0MAY\0JUN\0JUL\0AUG\0SEP\0OCT\0NOV\0DEC";
            unpackDateAndTime(ptr + 0x21, &year, &month, &day, &hour, &minute);
            if (month > 0)
            {
                if (year >= 2000)
                    year -= 2000;
                else
                    year -= 1900;
                [catString appendFormat:@" %2ld-%s-%02ld %2ld:%02ld ",
                 (long)day,
                 nameOfMonth + 4 * (month - 1),
                 (long)year,
                 (long)hour,
                 (long)minute];
            }
            else
                [catString appendString:@" <NO DATE>       "];
            
            // Created
            unpackDateAndTime(ptr + 0x18, &year, &month, &day, &hour, &minute);
            if (month > 0)
            {
                if (year >= 2000)
                    year -= 2000;
                else
                    year -= 1900;
                [catString appendFormat:@" %2ld-%s-%02ld %2ld:%02ld ",
                 (long)day,
                 nameOfMonth + 4 * (month - 1),
                 (long)year,
                 (long)hour,
                 (long)minute];
            }
            else
                [catString appendString:@" <NO DATE>       "];
            
            // EOF
            [catString appendFormat:@"%8d ", ptr[0x15] | (ptr[0x16] << 8) | (ptr[0x17] << 16)];
            
            // Aux Type
            if (fileType.typeId == BINARY_FILE_TYPE_ID)
                [catString appendFormat:@"A=$%04X", unpackWord(ptr + 0x1f)];
            else if (fileType.typeId == TEXT_FILE_TYPE_ID)
                [catString appendFormat:@"R=%5d", unpackWord(ptr + 0x1f)];
            
            [catString appendFormat:@"\n"];
        }
        index = 0;
        ++blockIndex;
        ptr = data.bytes + 512 * blockIndex + 4;
    } while (blockIndex < data.length / 512);

    // We have no choice but to go to the volume directory header to get
    // the total blocks
    ProDOSImage *diskImage = self.document;
    PDVolume *volume = (PDVolume *)diskImage.volume;

    [catString appendFormat:@"\nBLOCKS FREE:%5d     BLOCKS USED:%5d     TOTAL BLOCKS:%5lu\n",
     0,
     0,
     (unsigned long)volume.totalBlockCount];

    textView.string = catString;
}

- (IBAction)displayHexDump:(id)sender
{
    [self hexDump];
}

- (IBAction)displayApplesoftBasic:(id)sender
{
    textView.string = [Applesoft parseData:data hasHeader:header];
}

- (IBAction)display6502Disassembly:(id)sender
{
    textView.string = [Disassembler disassembleData:data
                                           withOffset:startAddress
                                            hasHeader:header];
}

- (IBAction)displayText:(id)sender
{
    NSString *str = [[NSString alloc] initWithBytes:data.bytes
                                             length:data.length
                                           encoding:[NSString defaultCStringEncoding]];
    textView.string = str;
}

- (IBAction)displayCatalog:(id)sender
{
    [self catalog];
}

@end
