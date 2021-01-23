//
//  Disassembler.m
//  Disk II
//
//  Created by David Schweinsberg on 14/01/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import "Disassembler.h"

@implementation Disassembler

+ (NSString *)disassembleData:(NSData *)data
                   withOffset:(NSUInteger)offset
                    hasHeader:(BOOL)aHeader {
  unsigned int byteCount[] = {
      //  0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
      1, 2, 1, 1, 1, 2, 2, 1, 1, 2, 1, 1, 1, 3, 3, 1, // 0x
      2, 2, 1, 1, 1, 2, 2, 1, 1, 3, 1, 1, 1, 3, 3, 1, // 1x
      3, 2, 1, 1, 2, 2, 2, 1, 1, 2, 1, 1, 3, 3, 3, 1, // 2x
      2, 2, 1, 1, 1, 2, 2, 1, 1, 3, 1, 1, 1, 3, 3, 1, // 3x
      1, 2, 1, 1, 1, 2, 2, 1, 1, 2, 1, 1, 3, 3, 3, 1, // 4x
      2, 2, 1, 1, 1, 2, 2, 1, 1, 3, 1, 1, 1, 3, 3, 1, // 5x
      1, 2, 1, 1, 1, 2, 2, 1, 1, 2, 1, 1, 3, 3, 3, 1, // 6x
      2, 2, 1, 1, 1, 2, 2, 1, 1, 3, 1, 1, 1, 3, 3, 1, // 7x

      1, 2, 1, 1, 2, 2, 2, 1, 1, 1, 1, 1, 3, 3, 3, 1, // 8x
      2, 2, 1, 1, 2, 2, 2, 1, 1, 3, 1, 1, 1, 3, 1, 1, // 9x
      2, 2, 2, 1, 2, 2, 2, 1, 1, 2, 1, 1, 3, 3, 3, 1, // Ax
      2, 2, 1, 1, 2, 2, 2, 1, 1, 3, 1, 1, 3, 3, 3, 1, // Bx
      2, 2, 1, 1, 2, 2, 2, 1, 1, 2, 1, 1, 3, 3, 3, 1, // Cx
      2, 2, 1, 1, 1, 2, 2, 1, 1, 3, 1, 1, 1, 3, 3, 1, // Dx
      2, 2, 1, 1, 2, 2, 2, 1, 1, 2, 1, 1, 3, 3, 3, 1, // Ex
      2, 2, 1, 1, 1, 2, 2, 1, 1, 3, 1, 1, 1, 3, 3, 1  // Fx
  };

  // 0 - (Indirect,X)
  // 1 - Zero Page
  // 2 - Immediate
  // 3 - Absolute
  // 4 - (Indirect),Y
  // 5 - Zero Page,X
  // 6 - Absolute,Y
  // 7 - Absolute,X
  // 8 - Accumulator
  // 9 - Relative
  // 10 - Implied
  // 11 - Indirect
  // 12 - Zero Page,Y
  unsigned int addrMode[] = {
      //   0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
      10, 0, 10, 10, 10, 1, 1,  10, 10, 2,  8,  10, 10, 3, 3,  10, // 0x
      9,  4, 10, 10, 10, 5, 5,  10, 10, 6,  10, 10, 10, 7, 7,  10, // 1x
      3,  0, 10, 10, 1,  1, 1,  10, 10, 2,  8,  10, 3,  3, 3,  10, // 2x
      9,  4, 10, 10, 10, 5, 5,  10, 10, 6,  10, 10, 10, 7, 7,  10, // 3x
      10, 0, 10, 10, 10, 1, 1,  10, 10, 2,  8,  10, 3,  3, 3,  10, // 4x
      9,  4, 10, 10, 10, 5, 5,  10, 10, 6,  10, 10, 10, 7, 7,  10, // 5x
      10, 0, 10, 10, 10, 1, 1,  10, 10, 2,  8,  10, 11, 3, 3,  10, // 6x
      9,  4, 10, 10, 10, 5, 5,  10, 10, 6,  10, 10, 10, 7, 7,  10, // 7x

      10, 0, 10, 10, 1,  1, 1,  10, 10, 10, 10, 10, 3,  3, 3,  10, // 8x
      9,  4, 10, 10, 5,  5, 12, 10, 10, 6,  10, 10, 10, 7, 10, 10, // 9x
      2,  0, 2,  10, 1,  1, 1,  10, 10, 2,  10, 10, 3,  3, 3,  10, // Ax
      9,  4, 10, 10, 5,  5, 12, 10, 10, 6,  10, 10, 7,  7, 6,  10, // Bx
      2,  0, 10, 10, 1,  1, 1,  10, 10, 2,  10, 10, 3,  3, 3,  10, // Cx
      9,  4, 10, 10, 10, 5, 5,  10, 10, 6,  10, 10, 10, 7, 7,  10, // Dx
      2,  0, 10, 10, 1,  1, 1,  10, 10, 2,  10, 10, 3,  3, 3,  10, // Ex
      9,  4, 10, 10, 10, 5, 5,  10, 10, 6,  10, 10, 10, 7, 7,  10  // Fx
  };

  NSString *mnem[] = {
      // x0      x1      x2      x3      x4      x5      x6      x7      x8
      // x9      xA      xB      xC      xD      xE      xF
      @"BRK", @"ORA", @"???", @"???", @"???", @"ORA", @"ASL", @"???", @"PHP",
      @"ORA", @"ASL", @"???", @"???", @"ORA", @"ASL", @"???", @"BPL", @"ORA",
      @"???", @"???", @"???", @"ORA", @"ASL", @"???", @"CLC", @"ORA", @"???",
      @"???", @"???", @"ORA", @"ASL", @"???", @"JSR", @"AND", @"???", @"???",
      @"BIT", @"AND", @"ROL", @"???", @"PLP", @"AND", @"ROL", @"???", @"BIT",
      @"AND", @"ROL", @"???", @"BMI", @"AND", @"???", @"???", @"???", @"AND",
      @"ROL", @"???", @"SEC", @"AND", @"???", @"???", @"???", @"AND", @"ROL",
      @"???", @"RTI", @"EOR", @"???", @"???", @"???", @"EOR", @"LSR", @"???",
      @"PHA", @"EOR", @"LSR", @"???", @"JMP", @"EOR", @"LSR", @"???", @"BVC",
      @"EOR", @"???", @"???", @"???", @"EOR", @"LSR", @"???", @"CLI", @"EOR",
      @"???", @"???", @"???", @"EOR", @"LSR", @"???", @"RTS", @"ADC", @"???",
      @"???", @"???", @"ADC", @"ROR", @"???", @"PLA", @"ADC", @"ROR", @"???",
      @"JMP", @"ADC", @"ROR", @"???", @"BVS", @"ADC", @"???", @"???", @"???",
      @"ADC", @"ROR", @"???", @"SEI", @"ADC", @"???", @"???", @"???", @"ADC",
      @"ROR", @"???",

      @"???", @"STA", @"???", @"???", @"STY", @"STA", @"STX", @"???", @"DEY",
      @"???", @"TXA", @"???", @"STY", @"STA", @"STX", @"???", @"BCC", @"STA",
      @"???", @"???", @"STY", @"STA", @"STX", @"???", @"TYA", @"STA", @"TXS",
      @"???", @"???", @"STA", @"???", @"???", @"LDY", @"LDA", @"LDX", @"???",
      @"LDY", @"LDA", @"LDX", @"???", @"TAY", @"LDA", @"TAX", @"???", @"LDY",
      @"LDA", @"LDX", @"???", @"BCS", @"LDA", @"???", @"???", @"LDY", @"LDA",
      @"LDX", @"???", @"CLV", @"LDA", @"TSX", @"???", @"LDY", @"LDA", @"LDX",
      @"???", @"CPY", @"CMP", @"???", @"???", @"CPY", @"CMP", @"DEC", @"???",
      @"INY", @"CMP", @"DEX", @"???", @"CPY", @"CMP", @"DEC", @"???", @"BNE",
      @"CMP", @"???", @"???", @"???", @"CMP", @"DEC", @"???", @"CLD", @"CMP",
      @"???", @"???", @"???", @"CMP", @"DEC", @"???", @"CPX", @"SBC", @"???",
      @"???", @"CPX", @"SBC", @"INC", @"???", @"INX", @"SBC", @"NOP", @"???",
      @"CPX", @"SBC", @"INC", @"???", @"BEQ", @"SBC", @"???", @"???", @"???",
      @"SBC", @"INC", @"???", @"SED", @"SBC", @"???", @"???", @"???", @"SBC",
      @"INC", @"???"};

  NSMutableString *str = [NSMutableString string];
  const unsigned char *startPtr = data.bytes;
  NSUInteger addr = 0;
  NSUInteger length = data.length;
  if (aHeader) {
    startPtr += 4;
    length -= 4;
  }

  while (addr < length) {
    // Address & hex
    [str appendFormat:@"%04lX-   ", addr + offset];

    unsigned int opCode = startPtr[addr];
    unsigned int bytes = byteCount[opCode];
    if (bytes == 1)
      [str appendFormat:@"%02X          %@", startPtr[addr], mnem[opCode]];
    else if (bytes == 2)
      [str appendFormat:@"%02X %02X       %@", startPtr[addr],
                        startPtr[addr + 1], mnem[opCode]];
    else if (bytes == 3)
      [str appendFormat:@"%02X %02X %02X    %@", startPtr[addr],
                        startPtr[addr + 1], startPtr[addr + 2], mnem[opCode]];

    // Adressing mode
    switch (addrMode[opCode]) {
    case 0: // (Indirect,X)
      [str appendFormat:@"   ($%02X,X)", startPtr[addr + 1]];
      break;
    case 1: // Zero Page
      [str appendFormat:@"   $%02X", startPtr[addr + 1]];
      break;
    case 2: // Immediate
      [str appendFormat:@"   #$%02X", startPtr[addr + 1]];
      break;
    case 3: // Absolute
      [str
          appendFormat:@"   $%02X%02X", startPtr[addr + 2], startPtr[addr + 1]];
      break;
    case 4: // (Indirect),Y
      [str appendFormat:@"   ($%02X),Y", startPtr[addr + 1]];
      break;
    case 5: // Zero Page,X
      [str appendFormat:@"   $%02X,X", startPtr[addr + 1]];
      break;
    case 6: // Absolute,Y
      [str appendFormat:@"   $%02X%02X,Y", startPtr[addr + 2],
                        startPtr[addr + 1]];
      break;
    case 7: // Absolute,X
      [str appendFormat:@"   $%02X%02X,X", startPtr[addr + 2],
                        startPtr[addr + 1]];
      break;
    case 8: // Accumulator
      [str appendFormat:@"   A"];
      break;
    case 9: // Relative
      [str appendFormat:@"   $%04lX",
                        offset + addr + bytes + (char)startPtr[addr + 1]];
      break;
    case 11: // Indirect
      [str appendFormat:@"   ($%02X%02X)", startPtr[addr + 2],
                        startPtr[addr + 1]];
      break;
    case 12: // Zero Page,Y
      [str appendFormat:@"   $%02X,Y", startPtr[addr + 1]];
      break;
    }

    [str appendString:@"\n"];
    addr += byteCount[opCode];
  }

  return str;
}

@end
