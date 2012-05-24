//
//  BasicEncodingRules.h
//
//  Created by Peter Suk on 5/16/12.
//  Copyright (c) Ooghamist LLC 2012. All rights reserved.
//
//  Distributed under the permissive zlib License
//  Get the latest version from here:
//
//  https://github.com/StCredZero/SCZ-BasicEncodingRules-iOS
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import <Foundation/Foundation.h>

// Bit 6 is primitive or constructed
//      8 7 6 5 4 3 2 1
//      ---------------
//      0 0 1 0 0 0 0 0

#define kBerTypeConstructed 0x20

// Bits 1 through 5 
//      8 7 6 5 4 3 2 1
//      ---------------
//      0 0 0 X X X X X

#define BER_EOC                 0X00
#define BER_BOOLEAN             0X01
#define BER_INTEGER             0X02
#define BER_BIT_STRING          0X03
#define BER_OCTET_STRING        0X04
#define BER_NULL                0X05
#define BER_OBJECT_IDENTIFIER   0X06
#define BER_OBJECT_DESCRIPTOR   0X07
#define BER_EXTERNAL            0X08
#define BER_REAL                0X09
#define BER_ENUMERATED          0X0A
#define BER_EMBEDDED PDV        0X0B
#define BER_UTF8STRING          0X0C
#define BER_RELATIVE_OID        0X0D
#define BER_RESERVED0X0E        0X0E
#define BER_RESERVED0X0F        0X0F
#define BER_SEQUENCE            0X10
#define BER_SET                 0X11
#define BER_NUMERICSTRING       0X12
#define BER_PRINTABLESTRING     0X13
#define BER_T61STRING           0X14
#define BER_VIDEOTEXSTRING      0X15
#define BER_IA5STRING           0X16
#define BER_UTCTIME             0X17
#define BER_GENERALIZEDTIME     0X18
#define BER_GRAPHICSTRING       0X19
#define BER_VISIBLESTRING       0X1A
#define BER_GENERALSTRING       0X1B
#define BER_UNIVERSALSTRING     0X1C
#define BER_CHARACTER_STRING    0X1D
#define BER_BMPSTRING           0X1E
#define BER_USE_LONG_FORM       0X1F

@interface NSObject (BasicEncodingRules)
- (void)raiseUnimplemented;
- (uint8_t*)berTag;
- (NSData*)berHeader;
- (NSData*)berData;
- (NSUInteger)berLengthBytes;
- (NSUInteger)berContentsLengthBytes;   
- (id)berDecode;
@end

@interface NSData (BasicEncodingRules)
- (uint8_t*)berTag;
- (NSData*)berData;
- (NSUInteger)berContentsLengthBytes;
@end

@interface NSArray (BasicEncodingRules)
- (uint8_t*)berTag;
- (NSData*)berData;
- (NSUInteger)berContentsLengthBytes;
@end