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
#include <objc/objc-runtime.h>

// Bits 7 and 8 
//      8 7 6 5 4 3 2 1
//      ---------------
//      X X 0 0 0 0 0 0

#define kBerClassUniversal          0x00
#define kBerClassApplication        0x40
#define kBerClassContextSpecific    0x80
#define kBerClassPrivate            0xC0

// Bit 6 is primitive or constructed
//      8 7 6 5 4 3 2 1
//      ---------------
//      0 0 1 0 0 0 0 0

#define kBerTypeConstructed 0x20

// Bits 1 through 5 
//      8 7 6 5 4 3 2 1
//      ---------------
//      0 0 0 X X X X X

#define BER_EOC                 0x00
#define BER_BOOLEAN             0x01
#define BER_INTEGER             0x02
#define BER_BIT_STRING          0x03
#define BER_OCTET_STRING        0x04
#define BER_NULL                0x05
#define BER_OBJECT_IDENTIFIER   0x06
#define BER_OBJECT_DESCRIPTOR   0x07
#define BER_EXTERNAL            0x08
#define BER_REAL                0x09
#define BER_ENUMERATED          0x0A
#define BER_EMBEDDED_PDV        0x0B
#define BER_UTF8STRING          0x0C
#define BER_RELATIVE_OID        0x0D
#define BER_RESERVED0X0E        0x0E
#define BER_RESERVED0X0F        0x0F
#define BER_SEQUENCE            0x10
#define BER_SET                 0x11
#define BER_NUMERICSTRING       0x12
#define BER_PRINTABLESTRING     0x13
#define BER_T61STRING           0x14
#define BER_VIDEOTEXSTRING      0x15
#define BER_IA5STRING           0x16
#define BER_UTCTIME             0x17
#define BER_GENERALIZEDTIME     0x18
#define BER_GRAPHICSTRING       0x19
#define BER_VISIBLESTRING       0x1A
#define BER_GENERALSTRING       0x1B
#define BER_UNIVERSALSTRING     0x1C
#define BER_CHARACTER_STRING    0x1D
#define BER_BMPSTRING           0x1E
#define BER_USE_LONG_FORM       0x1F

#define BER_A0                      (kBerClassContextSpecific | kBerTypeConstructed)
#define BER_SEQUENCE_CONSTRUCTED    (BER_SEQUENCE | kBerTypeConstructed)
#define BER_SET_CONSTRUCTED         (BER_SET | kBerTypeConstructed)

@interface BERVisitor : NSObject
- (id)visitBERLeafNode:(id)leaf;
- (id)visitBERInteriorNode:(id)node;
@end

@interface BERPrintVisitor : BERVisitor
{
    NSUInteger indentLevel;
    BOOL isIndenting;
    NSMutableString * string;
}
@property (nonatomic, assign) NSUInteger indentLevel;
@property (nonatomic, assign) BOOL isIndenting;
@property (nonatomic, strong) NSMutableString * string;
@end

@interface NSObject (BasicEncodingRules)

- (NSData*)berData;
- (uint8_t*)berTag;
- (NSData*)berHeader;
- (NSUInteger)berLengthBytes;
- (NSUInteger)berContentsLengthBytes;   
- (NSData*)berContents;

- (id)berDecode;
- (id)berParse;

//Utility Methods
- (void)raiseUnimplemented;
- (NSData*)zeroByteData;

- (NSString*)berTagDescription;
- (NSString*)berContentsDescription;

- (void)acceptBERVisitor:(BERVisitor*)visitor;
@end

@interface NSString (BasicEncodingRules)
- (NSData*)berDataUsingEncoding:(NSStringEncoding)encoding;
- (NSUInteger)berContentsLengthBytesUsingEncoding:(NSStringEncoding)encoding;
@end

@interface NSData (BasicEncodingRules)
@end

@interface NSArray (BasicEncodingRules)
@end

@interface NSNull (BasicEncodingRules)
@end

@interface BerTaggedObject : NSObject {
    uint8_t berTag[1];
    id obj;
    NSUInteger start;
    NSUInteger end;
}
@property (nonatomic, assign) uint8_t berTagValue;
@property (nonatomic, strong) id obj;
@property (nonatomic, assign) NSUInteger start;
@property (nonatomic, assign) NSUInteger end;
- (void)beMutable;
- (id)unwrapped;
- (NSString*)descriptionFormat;
@end

@interface BerTaggedCollection : BerTaggedObject {}
@property (nonatomic, strong) NSMutableArray *collection;
- (void)addObject:(id)anObject;
-(id)objectAtIndex:(NSUInteger)index;
@end

@interface BerTaggedData : BerTaggedObject {}
@property (nonatomic, strong) NSData *data;
@end

@interface BerTaggedString : BerTaggedObject {}
@property (nonatomic, strong) NSString *string;
@end

