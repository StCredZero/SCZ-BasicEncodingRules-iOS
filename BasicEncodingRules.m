//
//  BasicEncodingRules.m
//
//  Created by Peter Kwangjun Suk on 5/16/12.
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

#import "BasicEncodingRules.h"

@implementation BERVisitor : NSObject
- (id)visitBERLeafNode:(id)leaf
{
    [self raiseUnimplemented];
    return nil;
}
- (id)visitBERInteriorNode:(id)node
{
    [self raiseUnimplemented];
    return nil;
}
@end


@implementation BERPrintVisitor : BERVisitor
@synthesize indentLevel;
@synthesize isIndenting;
@synthesize string;
- (id) init
{
    if (self = [super init])
    {
        self.indentLevel = 0;
        self.isIndenting = YES;
        self.string = [[NSMutableString alloc] init];
    }
    return self;
}
- (id)visitBERLeafNode:(id)leaf
{
    NSString *tempString = [leaf berContentsDescription];

    [self berIndent];
    [self.string appendFormat:@"%@ ", [leaf berTagDescription]];
    if([tempString length] > 80) 
    {
        [self.string appendFormat:@"\n"];
        [self increaseIndent];
        [self berIndent];
    }
    for (NSUInteger i = 0; i < [tempString length]; i++)
    {
        [self.string appendFormat:@"%c", [tempString characterAtIndex:i]];
        if ((i > 0) && (i % 80 == 0)) 
        {
            [self.string appendFormat:@"\n"];
            [self berIndent];
        }
    }
    if([tempString length] > 80) 
    {
        [self decreaseIndent];
    }

    return nil;
}
- (id)visitBERInteriorNode:(id)node
{
    NSString *initialDelimiter = @"\n";
    NSString *middleDelimiter = @"\n";
    BOOL indentDelimiter = YES;
    BOOL indentState = self.isIndenting;
    if ([node berContentsLengthBytes] <= 20)
    {
        initialDelimiter = @"";
        middleDelimiter = @", ";
        indentDelimiter = NO;
    }
    [self berIndent];
    if ( ! indentDelimiter) self.isIndenting = NO;

    [self.string appendFormat:@"%@ ( %@", 
     [node berTagDescription],
     initialDelimiter];
    [self increaseIndent];
    NSUInteger count = [[node collection] count];
    for (NSUInteger i = 0; i < count; i++) 
    {
        id childNode = [[node collection] objectAtIndex:i];
        [childNode acceptBERVisitor:self];
        if (i < count - 1) [self.string appendFormat:middleDelimiter];
    }
    [self decreaseIndent];
    [self.string appendFormat:@" )"];
    self.isIndenting = indentState;

    return nil;
}
- (void)berIndent
{
    if (self.isIndenting)
    {
        for (NSUInteger i = 0; i < self.indentLevel; i++)
        {
            [self.string appendFormat:@"%@", @"    "];
        }
    }
}
- (void)increaseIndent
{
    self.indentLevel = self.indentLevel + 1;
}
- (void)decreaseIndent
{
    self.indentLevel = self.indentLevel - 1;

}
@end



@implementation NSObject (BasicEncodingRules)

#pragma mark - NSObject Encoding

- (NSData*)berData
{
    NSMutableData *berData = [[NSMutableData  alloc] init];
    [berData appendData:[self berHeader]];
    [berData appendData:[self berContents]];
    return berData;
}

- (uint8_t*)berTag {
    [self raiseUnimplemented];
    return nil;
}

- (NSData*)berHeader
{
    NSMutableData *berHeader = [[NSMutableData  alloc] init];
    [berHeader appendBytes:[self berTag] length:1];
    [berHeader appendData:[self lengthStorageData]];
    return berHeader;
}

- (NSData*)berContents {
    [self raiseUnimplemented];
    return nil;
}

- (NSUInteger)berLengthBytes
{
    NSUInteger berContentsLengthBytes = [self berContentsLengthBytes];
    if (berContentsLengthBytes <= 0x7F) {
        return 2 + berContentsLengthBytes;
    }
    return 2 + [self lengthBytesLog8] + berContentsLengthBytes; 
}

- (NSUInteger)berContentsLengthBytes 
{
    [self raiseUnimplemented];
    return 0;
}

- (NSUInteger)lengthBytesLog8
{
    NSUInteger lengthBytes = 0;
    NSUInteger myLength = [self berContentsLengthBytes];
    for (NSUInteger tempLength = myLength; tempLength > 0; lengthBytes++) {
        tempLength >>= 8;
    }
    return lengthBytes;
}

- (NSData*)lengthStorageData
{
    NSMutableData *lengthStorageData = [[NSMutableData alloc] init];
    uint8_t lengthBytesTag[1];
    NSUInteger contentsLength = [self berContentsLengthBytes];
    if (contentsLength > 0x7F) {
        NSUInteger lengthStorageBytes = [self lengthBytesLog8];
        if (lengthStorageBytes > sizeof(NSUInteger))
            [NSException 
             raise:@"Invalid length value" 
             format:@"length storage greater than %d bytes is invalid", lengthStorageBytes];
        lengthBytesTag[0] = 0x80 + lengthStorageBytes;
        [lengthStorageData appendBytes:lengthBytesTag length:1];
        uint8_t temp[sizeof(NSUInteger)];
        NSInteger bitOffset;
        for (NSInteger i = 0; i < lengthStorageBytes; i++) {
            bitOffset = (lengthStorageBytes - i - 1)*8;
            temp[i] = (contentsLength & (0xFF << bitOffset)) >> bitOffset;
        }
        [lengthStorageData appendBytes:temp length:lengthStorageBytes];
    }
    else {
        lengthBytesTag[0] = contentsLength;
        [lengthStorageData appendBytes:lengthBytesTag length:1];
    }
    return lengthStorageData;
}

#pragma mark - NSObject Decoding

- (id)berDecode {
    [self raiseUnimplemented];
    return nil;
}

- (id)berParse {
    [self raiseUnimplemented];
    return nil;
}

#pragma mark - BERVisitor

- (void)acceptBERVisitor:(BERVisitor*)visitor
{
    [visitor visitBERLeafNode:(id)self];
}

#pragma mark - NSObject Printing

- (NSString*)berContentsDescription
{
    return [NSString string];
}

#pragma mark - NSObject Utility

- (NSData*)zeroByteData
{
    static uint8_t zero[] = { 0x00 };
    NSMutableData *zeroByteData = [[NSMutableData  alloc] init];
    [zeroByteData appendBytes:zero length:1];
    return zeroByteData;
}

- (void)raiseUnimplemented {
    [NSException 
     raise:@"Invalid BER translation" 
     format:@"unimplemented for this type"];
}

- (NSString*)berTagDescription
{
    uint8_t *tagBytes = [self berTag];
    NSString *desc;
    switch (tagBytes[0]) {
        case BER_A0:
            desc = @"A0";
            break;
        case BER_EOC: 
            desc = @"EOC";                
            break;              
        case BER_BOOLEAN: 
            desc = @"BOOL";            
            break;              
        case BER_INTEGER: 
            desc = @"INTEGER";            
            break;              
        case BER_BIT_STRING: 
            desc = @"BIT_STR";         
            break;              
        case BER_OCTET_STRING: 
            desc = @"OCTET_STR";       
            break;              
        case BER_NULL: 
            desc = @"NULL";               
            break;              
        case BER_OBJECT_IDENTIFIER: 
            desc = @"OID";  
            break;              
        case BER_OBJECT_DESCRIPTOR: 
            desc = @"OBJ_DESC";  
            break;              
        case BER_EXTERNAL: 
            desc = @"EXTERNAL";           
            break;              
        case BER_REAL: 
            desc = @"REAL";               
            break;              
        case BER_ENUMERATED: 
            desc = @"ENUM";         
            break;              
        case BER_EMBEDDED_PDV: 
            desc = @"EMBED_PDV";        
            break;              
        case BER_UTF8STRING: 
            desc = @"UTF8_STR";         
            break;              
        case BER_RELATIVE_OID: 
            desc = @"RELATIVE_OID";       
            break;              
        case BER_RESERVED0X0E:
            desc = @"RESERVED0x0E";
            break;              
        case BER_RESERVED0X0F:
            desc = @"RESERVED0x0F";      
            break;              
        case BER_SEQUENCE: 
            desc = @"SEQ";           
            break;              
        case BER_SET: 
            desc = @"SET";                
            break;              
        case BER_NUMERICSTRING: 
            desc = @"NUM_STR";      
            break;              
        case BER_PRINTABLESTRING: 
            desc = @"PRINTABLE_STR";    
            break;              
        case BER_T61STRING: 
            desc = @"T61_STR";          
            break;              
        case BER_VIDEOTEXSTRING: 
            desc = @"VIDTEX_STR";     
            break;              
        case BER_IA5STRING: 
            desc = @"IA5_STR";          
            break;              
        case BER_UTCTIME: 
            desc = @"UTCTIME";            
            break;              
        case BER_GENERALIZEDTIME: 
            desc = @"GEN_TIME";    
            break;              
        case BER_GRAPHICSTRING: 
            desc = @"GRAPHIC_STR";      
            break;              
        case BER_VISIBLESTRING: 
            desc = @"VIS_STR";      
            break;              
        case BER_GENERALSTRING: 
            desc = @"GEN_STR";      
            break;              
        case BER_UNIVERSALSTRING: 
            desc = @"UNIV_STR";    
            break;              
        case BER_CHARACTER_STRING: 
            desc = @"CHAR_STR";   
            break;              
        case BER_BMPSTRING: 
            desc = @"BMP_STR";          
            break;              
        case BER_USE_LONG_FORM: 
            desc = @"USE_LONG_FORM";      
            break;       
        case BER_SEQUENCE_CONSTRUCTED:
            desc = @"SEQ_CONSTR";
            break;
        case BER_SET_CONSTRUCTED:
            desc = @"SET_CONSTR";
            break;
        default:
            desc = @"UNKNOWN";
    }
    return [NSString stringWithString:desc]; 
}

@end

#pragma mark - BER Subclasses
@implementation BerTaggedObject : NSObject
@synthesize obj;
@synthesize start;
@synthesize end;
- (void)beMutable
{
    
}
- (id)unwrapped
{
    return self.obj;
}
- (uint8_t*)berTag
{
    return berTag;
}
- (void)setBerTagValue:(uint8_t)newValue
{
    berTag[0] = newValue;
}
- (uint8_t)berTagValue
{
    return berTag[0];
}
- (BOOL)isEqual:(id)other
{   
    if ([other isKindOfClass:[BerTaggedObject class]])
    {
        BerTaggedObject *taggedObj = other;
        return (self.berTagValue == taggedObj.berTagValue 
                && [self.obj isEqual:taggedObj.obj]);
    }
    return NO;
}
- (NSUInteger)berContentsLengthBytes
{
    if (self.obj)
    {
        return [self.obj berContentsLengthBytes];
    }
    return [super berContentsLengthBytes];
}
- (NSUInteger)berLengthBytes
{
    if (self.obj)
    {
        return [self.obj berLengthBytes];
    }
    return [super berLengthBytes];
}
- (NSString*)descriptionFormat
{
    return [NSString stringWithString:@"<%@ %@>"];
}
- (NSString*)description
{
    if (self.obj)
    {
        return [NSString stringWithFormat:[self descriptionFormat], 
                [self berTagDescription], 
                [self.obj description]];
    }
    return [self berTagDescription];
}
- (NSData*)berContents
{
    [self raiseUnimplemented];
    return nil;
}
- (NSData*)lengthStorageData
{
    if (self.obj)
    {
        return [self.obj lengthStorageData];
    }
    return [self zeroByteData];
} 
- (NSString*)berContentsDescription
{
    return [self.obj berContentsDescription];
}
@end

@implementation BerTaggedCollection : BerTaggedObject
- (void)beMutable
{
    NSMutableArray *newArray = [[NSMutableArray alloc] initWithCapacity:[self.collection count]];
    [newArray addObjectsFromArray:self.collection];
    self.collection = newArray;
    for (NSUInteger i = 0; i < [self.collection count]; i++) {
        [[self.collection objectAtIndex:i] beMutable];
    }
}
- (id)unwrapped
{
    for (NSUInteger i = 0; i < [self.collection count]; i++) {
        BerTaggedObject *item = [self.collection objectAtIndex:i];
        id unwrapped = [item unwrapped];
        [self.collection replaceObjectAtIndex:i withObject:unwrapped];
    }
    return self.obj;
}
- (NSData*)berContents
{
    NSMutableData *berContents = [[NSMutableData  alloc] init];
    for (NSUInteger i = 0; i < [self.collection count]; i++) {
        [berContents appendData:[[self.collection objectAtIndex:i] berData]];
    }
    return berContents;
}
- (void)setCollection:(NSMutableArray*)aCollection
{
    self.obj = aCollection;
}
- (NSArray*)collection
{
    return self.obj;
}
- (void)addObject:(id)anObject
{
    [self.obj addObject:anObject];
}
-(id)objectAtIndex:(NSUInteger)index
{
    return [self.collection objectAtIndex:index];
}

#pragma mark - BERVisitor

- (void)acceptBERVisitor:(BERVisitor*)visitor
{
    [visitor visitBERInteriorNode:(id)self];
}

@end


@implementation BerTaggedData : BerTaggedObject
- (void)setData:(NSData*)newData
{
    self.obj = newData;
}
- (NSData*)data
{
    return self.obj;
}
- (NSData*)berContents
{
    return self.data;
}
@end

@implementation BerTaggedString : BerTaggedObject
- (void)setString:(NSString*)newData
{
    self.obj = (id)newData;
}
- (NSString*)string
{
    return (NSString*)self.obj;
}
- (NSString*)descriptionFormat
{
    return [NSString stringWithString:@"%@\"%@\""];
}
- (NSStringEncoding)berStringEncoding
{
    NSStringEncoding encoding = NSUTF8StringEncoding;
    if  (self.berTagValue == BER_IA5STRING) 
    {
        encoding = NSASCIIStringEncoding;
    }
    return encoding;
}
- (NSData*)berData 
{
    NSMutableData *berData = [[NSMutableData alloc] init];
    [berData setData:[self.string berDataUsingEncoding:[self berStringEncoding]]];
    [berData replaceBytesInRange:NSMakeRange(0,1) withBytes:[self berTag]];
    return berData;
}
- (NSUInteger)berContentsLengthBytes
{
    return [self.string berContentsLengthBytesUsingEncoding:[self berStringEncoding]];
}

@end

@implementation NSString (BasicEncodingRules)
- (NSUInteger)berContentsLengthBytesUsingEncoding:(NSStringEncoding)encoding
{
    NSUInteger myLength = [self lengthOfBytesUsingEncoding:encoding];
    return myLength;
}

- (NSUInteger)berContentsLengthBytes
{
    return [self berContentsLengthBytesUsingEncoding:NSUTF8StringEncoding];
}

- (uint8_t*)berTag
{
    static uint8_t myTag[] = { BER_UTF8STRING };
    return myTag;
}

- (NSData*)berDataUsingEncoding:(NSStringEncoding)encoding
{
    NSMutableData *berData = [[NSMutableData alloc] init];
    [berData appendData:[self berHeader]];
    [berData appendData:[self dataUsingEncoding:encoding]];
    return berData;
}

- (NSData*)berData
{
    return [self berDataUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark - NSData Printing
- (NSString*)berContentsDescription
{
    return self;
}
@end

@implementation NSData (BasicEncodingRules)

#pragma mark - NSData Encoding

- (NSUInteger)berContentsLengthBytes
{
    NSUInteger myLength = [self length];
    return myLength;
}

- (uint8_t*)berTag
{
    static uint8_t integerTag[] = { BER_INTEGER };
    return integerTag;
}

- (NSData*)berContents
{
    return self;
}

#pragma mark - NSData Decoding

- (id)berParse
{
    NSUInteger iterator = 0;
    return [self berDecodeFromStart:0 
                                 to:[self length] - 1
                           iterator:&iterator];
}

- (id)berDecode
{
    id decoded = [self berParse];
    [decoded beMutable];
    return [decoded unwrapped];
}

- (id)berDecodeFromStart:(NSUInteger)start to:(NSUInteger)end iterator:(NSUInteger*)iterator
{
    uint8_t *bytes = (uint8_t*)[self bytes];
    uint8_t currentTag = bytes[start];
    
    switch (currentTag) 
    {
        case BER_A0:
        case BER_SEQUENCE_CONSTRUCTED:
        case BER_SET_CONSTRUCTED:
        case BER_SEQUENCE:
        case BER_SET:
            return [self berDecodeAsCollectionTagged:currentTag 
                                                from:start 
                                                  to:end];
            break;
        case BER_EOC:
        case BER_BOOLEAN:
        case BER_INTEGER:
        case BER_BIT_STRING:
        case BER_OCTET_STRING:
        case BER_NULL:
        case BER_OBJECT_IDENTIFIER:
        case BER_OBJECT_DESCRIPTOR:
        case BER_RELATIVE_OID:
            return [self berDecodeAsDataTagged:currentTag 
                                          from:start 
                                            to:end];
            break;
        case BER_UTF8STRING:
        case BER_NUMERICSTRING:
        case BER_PRINTABLESTRING:
        case BER_T61STRING:
        case BER_VIDEOTEXSTRING:
        case BER_IA5STRING:
        case BER_UTCTIME:
        case BER_GENERALIZEDTIME:
        case BER_GRAPHICSTRING:
        case BER_VISIBLESTRING:
        case BER_GENERALSTRING:
        case BER_UNIVERSALSTRING:
        case BER_CHARACTER_STRING:
        case BER_BMPSTRING:
            return [self berDecodeAsStringTagged:currentTag 
                                            from:start 
                                              to:end];
            break;
        default:
            [self raiseUnimplemented];
    }
    return nil;
}

- (NSUInteger)berDecodeSizeAt:(NSUInteger*)iterator
{
    uint8_t *bytes = (uint8_t*)[self bytes];
    NSUInteger iter = *iterator;
    NSUInteger container_length = 0, num_bytes = 1;
        
    iter++; // Skip the tag byte
    if (bytes[iter] > 0x80)
    {
        num_bytes = bytes[iter] - 0x80;
        iter++;
    }
    for (NSUInteger i = 0; i < num_bytes; i++)
    {
        container_length = (container_length * 0x100) + bytes[iter + i];
    }
    *iterator = iter + num_bytes;
    return container_length;
}

- (id)berDecodeAsCollection:(id)collection from:(NSUInteger)start to:(NSUInteger)end
{
    NSUInteger iterator = start;
    NSUInteger container_length, container_end;
    
    container_length = [self berDecodeSizeAt:&iterator];
    container_end = iterator + container_length;
    
    while (iterator < container_end)
    {
        NSUInteger item_start = iterator;
        NSUInteger item_length = [self berDecodeSizeAt:&iterator];
        NSUInteger next_item_start = iterator + item_length;

        id item = [self berDecodeFromStart:item_start 
                                        to:(next_item_start - 1)
                                  iterator:&iterator];
        [collection addObject: item];
        
        iterator = next_item_start;
    }
    return collection;
}

- (NSMutableSet*)berDecodeAsCollectionTagged:(uint8_t)tagValue from:(NSUInteger)start to:(NSUInteger)end
{
    BerTaggedCollection *newSet = [[BerTaggedCollection alloc] init];
    newSet.berTagValue = tagValue;
    newSet.collection = [[NSMutableArray alloc] init];
    newSet.start = start;
    newSet.end = end;
    return [self berDecodeAsCollection:newSet from:start to:end];
}
              
- (NSData*)berDecodeAsDataFrom:(NSUInteger)start to:(NSUInteger)end
{
    NSUInteger iterator = start;
    NSUInteger item_length = [self berDecodeSizeAt:&iterator];
    NSUInteger item_start = iterator;
    return [self subdataWithRange:NSMakeRange(item_start, item_length)];
}

- (BerTaggedData*)berDecodeAsDataTagged:(uint8_t)tagValue from:(NSUInteger)start to:(NSUInteger)end
{
    BerTaggedData *newData = [[BerTaggedData alloc] init];
    newData.data = [self berDecodeAsDataFrom:start to:end];
    newData.berTagValue = tagValue;
    newData.start = start;
    newData.end = end;
    return newData;
}

- (NSString*)berDecodeAsStringFrom:(NSUInteger)start to:(NSUInteger)end
{
    NSUInteger iterator = start;
    NSUInteger item_length = [self berDecodeSizeAt:&iterator];
    NSUInteger item_start = iterator;
    NSData *rawData = [self subdataWithRange:NSMakeRange(item_start, item_length)];
    return [[NSString alloc] initWithData:rawData encoding:NSUTF8StringEncoding ];
}

- (BerTaggedString*)berDecodeAsStringTagged:(uint8_t)tagValue from:(NSUInteger)start to:(NSUInteger)end
{
    BerTaggedString *newString = [[BerTaggedString alloc] init];
    newString.string = [self berDecodeAsStringFrom:start to:end];
    newString.berTagValue = tagValue;
    newString.start = start;
    newString.end = end;
    return newString;
}

#pragma mark - NSData Printing
- (NSString*)berContentsDescription
{
    uint8_t *bytes = (uint8_t*)[self bytes];
    NSMutableString *aString = [[NSMutableString alloc] init];
    for (NSUInteger i = 0; i < [self length]; i++) 
    {
        [aString appendFormat:@"%02X", bytes[i]];
    }
    return aString;
}
@end


@implementation NSArray (BasicEncodingRules)

#pragma mark - NSArray Encoding

- (NSUInteger)berContentsLengthBytes
{
    NSUInteger subTotalLength = 0;
    for (NSUInteger i = 0; i < [self count]; i++) {
        subTotalLength += [[self objectAtIndex:i] berLengthBytes];
    }
    return subTotalLength; 
}

- (uint8_t*)berTag
{
    static uint8_t bitfieldTag[] = { (kBerTypeConstructed | BER_SEQUENCE) };
    return bitfieldTag;
}

- (NSData*)berContents
{
    NSMutableData *berContents = [[NSMutableData  alloc] init];
    for (NSUInteger i = 0; i < [self count]; i++) {
        // A BER_SEQUENCE's berContents data is the sum of
        // all contained item's represented data.
        // Basically, it does not include the length data
        // That's why we're invoking berData below
        NSData *itemData = [[self objectAtIndex:i] berData]; 
        [berContents appendData:itemData];
    }
    return berContents;
}

#pragma mark - BERVisitor

- (void)acceptBERVisitor:(BERVisitor*)visitor
{
    [visitor visitBERInteriorNode:(id)self];
}

- (NSArray*)collection
{
    return self;
}

@end

@implementation NSNull (BasicEncodingRules)

#pragma mark - NSNull Encoding

- (NSUInteger)berContentsLengthBytes
{
    return 0; 
}

- (NSUInteger)berLengthBytes
{
    return 2;
}

- (uint8_t*)berTag
{
    static uint8_t bitfieldTag[] = { BER_NULL };
    return bitfieldTag;
}

- (NSData*)lengthStorageData
{
    return [self zeroByteData];
}

- (NSData*)berData
{
    return [self berHeader];
}

@end
