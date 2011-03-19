//
//  Applesoft.m
//  Disk II
//
//  Created by David Schweinsberg on 13/01/08.
//  Copyright 2008 David Schweinsberg. All rights reserved.
//

#import "Applesoft.h"


@implementation Applesoft

+ (NSString *)keywordForToken:(unsigned int)token
{
    switch (token)
    {
        case 128:
            return @"END";
        case 129:
            return @"FOR";
        case 130:
            return @"NEXT";
        case 131:
            return @"DATA";
        case 132:
            return @"INPUT";
        case 133:
            return @"DEL";
        case 134:
            return @"DIM";
        case 135:
            return @"READ";
        case 136:
            return @"GR";
        case 137:
            return @"TEXT";
        case 138:
            return @"PR#";
        case 139:
            return @"IN#";
        case 140:
            return @"CALL";
        case 141:
            return @"PLOT";
        case 142:
            return @"HLIN";
        case 143:
            return @"VLIN";
        case 144:
            return @"HGR2";
        case 145:
            return @"HGR";
        case 146:
            return @"HCOLOR=";
        case 147:
            return @"HPLOT";
        case 148:
            return @"DRAW";
        case 149:
            return @"XDRAW";
        case 150:
            return @"HTAB";
        case 151:
            return @"HOME";
        case 152:
            return @"ROT=";
        case 153:
            return @"SCALE=";
        case 154:
            return @"SHLOAD";
        case 155:
            return @"TRACE";
        case 156:
            return @"NOTRACE";
        case 157:
            return @"NORMAL";
        case 158:
            return @"INVERSE";
        case 159:
            return @"FLASH";
        case 160:
            return @"COLOR=";
        case 161:
            return @"POP";
        case 162:
            return @"VTAB";
        case 163:
            return @"HIMEM:";
        case 164:
            return @"LOMEM:";
        case 165:
            return @"ONERR";
        case 166:
            return @"RESUME";
        case 167:
            return @"RECALL";
        case 168:
            return @"STORE";
        case 169:
            return @"SPEED=";
        case 170:
            return @"LET";
        case 171:
            return @"GOTO";
        case 172:
            return @"RUN";
        case 173:
            return @"IF";
        case 174:
            return @"RESTORE";
        case 175:
            return @"&";
        case 176:
            return @"GOSUB";
        case 177:
            return @"RETURN";
        case 178:
            return @"REM";
        case 179:
            return @"STOP";
        case 180:
            return @"ON";
        case 181:
            return @"WAIT";
        case 182:
            return @"LOAD";
        case 183:
            return @"SAVE";
        case 184:
            return @"DEF";
        case 185:
            return @"POKE";
        case 186:
            return @"PRINT";
        case 187:
            return @"CONT";
        case 188:
            return @"LIST";
        case 189:
            return @"CLEAR";
        case 190:
            return @"GET";
        case 191:
            return @"NEW";
        case 192:
            return @"TAB(";
        case 193:
            return @"TO";
        case 194:
            return @"FN";
        case 195:
            return @"SPC(";
        case 196:
            return @"THEN";
        case 197:
            return @"AT";
        case 198:
            return @"NOT";
        case 199:
            return @"STEP";
        case 200:
            return @"+";
        case 201:
            return @"-";
        case 202:
            return @"*";
        case 203:
            return @"/";
        case 204:
            return @"^";
        case 205:
            return @"AND";
        case 206:
            return @"OR";
        case 207:
            return @">";
        case 208:
            return @"=";
        case 209:
            return @"<";
        case 210:
            return @"SGN";
        case 211:
            return @"INT";
        case 212:
            return @"ABS";
        case 213:
            return @"USR";
        case 214:
            return @"FRE";
        case 215:
            return @"SCRN(";
        case 216:
            return @"PDL";
        case 217:
            return @"POS";
        case 218:
            return @"SQR";
        case 219:
            return @"RND";
        case 220:
            return @"LOG";
        case 221:
            return @"EXP";
        case 222:
            return @"COS";
        case 223:
            return @"SIN";
        case 224:
            return @"TAN";
        case 225:
            return @"ATN";
        case 226:
            return @"PEEK";
        case 227:
            return @"LEN";
        case 228:
            return @"STR$";
        case 229:
            return @"VAL";
        case 230:
            return @"ASC";
        case 231:
            return @"CHR$";
        case 232:
            return @"LEFT$";
        case 233:
            return @"RIGHT$";
        case 234:
            return @"MID$";
    }
    return nil;
}

+ (NSString *)parseData:(NSData *)data hasHeader:(BOOL)aHeader
{
    NSMutableString *str = [NSMutableString string];
    const unsigned char *startPtr = [data bytes];
    if (aHeader)
        startPtr += 2;
    const unsigned char *linePtr = startPtr;
    unsigned int link;
    
    while ((link = linePtr[0] | (linePtr[1] << 8)))
    {
        // Line number
        unsigned int lineNo = linePtr[2] | (linePtr[3] << 8);
        [str appendFormat:@" %d ", lineNo];
        
        // Each of the tokens or characters on the line
        const unsigned char *ptr = linePtr + 4;
        while (*ptr)
        {
            if (*ptr > 127)
                [str appendFormat:@" %@ ", [Applesoft keywordForToken:*ptr]];
            else
                [str appendFormat:@"%c", *ptr];
            ++ptr;
        }
        [str appendString:@"\n"];
        
        // Move to the next line
        linePtr = startPtr + (link - 0x801);
    }
    return str;
}

@end
