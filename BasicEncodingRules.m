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


@implementation NSObject (BasicEncodingRules)

#pragma mark - NSObject Encoding

- (void)raiseUnimplemented {
    [NSException 
     raise:@"Invalid BER translation" 
     format:@"unimplemented for this type"];
}

- (uint8_t*)berTag {
    [self raiseUnimplemented];
    return nil;
}

- (NSData*)zeroByteData
{
    static uint8_t zero[] = { 0x00 };
    NSMutableData *zeroByteData = [[NSMutableData  alloc] init];
    [zeroByteData appendBytes:zero length:1];
    return zeroByteData;
}

- (NSString*)berTagDescription
{
    uint8_t *tagBytes = [self berTag];
    NSString *desc;
    switch (tagBytes[0]) {
        case BER_A0:
            desc = @"BER_A0";
            break;
        case BER_EOC: 
            desc = @"BER_EOC";                
            break;              
        case BER_BOOLEAN: 
            desc = @"BER_BOOLEAN";            
            break;              
        case BER_INTEGER: 
            desc = @"BER_INTEGER";            
            break;              
        case BER_BIT_STRING: 
            desc = @"BER_BIT_STRING";         
            break;              
        case BER_OCTET_STRING: 
            desc = @"BER_OCTET_STRING";       
            break;              
        case BER_NULL: 
            desc = @"BER_NULL";               
            break;              
        case BER_OBJECT_IDENTIFIER: 
            desc = @"BER_OBJECT_IDENTIFIER";  
            break;              
        case BER_OBJECT_DESCRIPTOR: 
            desc = @"BER_OBJECT_DESCRIPTOR";  
            break;              
        case BER_EXTERNAL: 
            desc = @"BER_EXTERNAL";           
            break;              
        case BER_REAL: 
            desc = @"BER_REAL";               
            break;              
        case BER_ENUMERATED: 
            desc = @"BER_ENUMERATED";         
            break;              
        case BER_EMBEDDED_PDV: 
            desc = @"BER_EMBEDDED_PDV";        
            break;              
        case BER_UTF8STRING: 
            desc = @"BER_UTF8STRING";         
            break;              
        case BER_RELATIVE_OID: 
            desc = @"BER_RELATIVE_OID";       
            break;              
        case BER_RESERVED0X0E:
            desc = @"BER_RESERVED0x0E";
            break;              
        case BER_RESERVED0X0F:
            desc = @"BER_RESERVED0x0F";      
            break;              
        case BER_SEQUENCE: 
            desc = @"BER_SEQUENCE";           
            break;              
        case BER_SET: 
            desc = @"BER_SET";                
            break;              
        case BER_NUMERICSTRING: 
            desc = @"BER_NUMERICSTRING";      
            break;              
        case BER_PRINTABLESTRING: 
            desc = @"BER_PRINTABLESTRING";    
            break;              
        case BER_T61STRING: 
            desc = @"BER_T61STRING";          
            break;              
        case BER_VIDEOTEXSTRING: 
            desc = @"BER_VIDEOTEXSTRING";     
            break;              
        case BER_IA5STRING: 
            desc = @"BER_IA5STRING";          
            break;              
        case BER_UTCTIME: 
            desc = @"BER_UTCTIME";            
            break;              
        case BER_GENERALIZEDTIME: 
            desc = @"BER_GENERALIZEDTIME";    
            break;              
        case BER_GRAPHICSTRING: 
            desc = @"BER_GRAPHICSTRING";      
            break;              
        case BER_VISIBLESTRING: 
            desc = @"BER_VISIBLESTRING";      
            break;              
        case BER_GENERALSTRING: 
            desc = @"BER_GENERALSTRING";      
            break;              
        case BER_UNIVERSALSTRING: 
            desc = @"BER_UNIVERSALSTRING";    
            break;              
        case BER_CHARACTER_STRING: 
            desc = @"BER_CHARACTER_STRING";   
            break;              
        case BER_BMPSTRING: 
            desc = @"BER_BMPSTRING";          
            break;              
        case BER_USE_LONG_FORM: 
            desc = @"BER_USE_LONG_FORM";      
            break;       
        case BER_SEQUENCE_CONSTRUCTED:
            desc = @"BER_SEQUENCE_CONSTRUCTED";
            break;
        case BER_SET_CONSTRUCTED:
            desc = @"BER_SET_CONSTRUCTED";
            break;
        default:
            desc = @"UNKNOWN";
    }
    return [NSString stringWithString:desc]; 
}

- (NSData*)berHeader
{
    NSMutableData *berHeader = [[NSMutableData  alloc] init];
    [berHeader appendBytes:[self berTag] length:1];
    [berHeader appendData:[self lengthStorageData]];
    return berHeader;
}

- (NSData*)berData {
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

- (NSUInteger)berContentsLengthBytes {
    [self raiseUnimplemented];
    return 0;
}

- (void)raiseBerExceptionForLengthZero:(NSInteger)lengthBytes {
    if (lengthBytes == 0)
        [NSException 
         raise:@"Invalid length value" 
         format:@"byte length of 0 is invalid"];
}

- (NSUInteger)lengthBytesLog8
{
    NSUInteger lengthBytes = 0;
    NSUInteger myLength = [self berContentsLengthBytes];
    for (NSUInteger tempLength = myLength; tempLength > 0; lengthBytes++) {
        tempLength >>= 8;
    }
    [self raiseBerExceptionForLengthZero:lengthBytes];
    return lengthBytes;
}

- (NSData*)lengthStorageData
{
    NSMutableData *lengthStorageData = [[NSMutableData alloc] init];
    uint8_t lengthBytesTag[1];
    NSUInteger contentsLength = [self berContentsLengthBytes];
    [self raiseBerExceptionForLengthZero:contentsLength];
    if (contentsLength > 0x7F) {
        NSUInteger lengthStorageBytes = [self lengthBytesLog8];
        [self raiseBerExceptionForLengthZero:lengthStorageBytes];
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

@end

#pragma mark - BER Subclasses
@implementation BerTaggedObject : NSObject
@synthesize obj;
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
- (NSUInteger)berContentsLengthBytes
{
    if (self.obj)
    {
        return [self.obj berContentsLengthBytes];
    }
    else
    {
        return 0;
    }
}
- (NSUInteger)berLengthBytes
{
    if (self.obj)
    {
        return [self.obj berLengthBytes];
    }
    else
    {
        return 2;
    }
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
    else
    {
        return [self berTagDescription];
    }
}
- (NSData*)berBody
{
    [self raiseUnimplemented];
    return nil;
}
- (NSData*)berData
{
    NSMutableData *berData = [[NSMutableData  alloc] init];
    [berData appendData:[self berHeader]];
    [berData appendData:[self berBody]];
    return berData;
} 
- (NSData*)lengthStorageData
{
    if (self.obj)
    {
        return [self.obj lengthStorageData];
    }
    else
    {
        return [self zeroByteData];
    }
} 
@end

@implementation BerTaggedCollection : BerTaggedObject
/*- (uint8_t*)berTag 
{
    return [super berTag];
}
- (NSData*)berHeader
{
    return [super berHeader];
}*/
- (NSData*)berBody
{
    NSMutableData *berBody = [[NSMutableData  alloc] init];
    for (NSUInteger i = 0; i < [self.collection count]; i++) {
        [berBody appendData:[[self.collection objectAtIndex:i] berData]];
    }
    return berBody;
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
- (NSData*)berBody
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
    [self raiseBerExceptionForLengthZero:myLength];
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
@end

@implementation NSData (BasicEncodingRules)

#pragma mark - NSData Encoding

- (NSUInteger)berContentsLengthBytes
{
    NSUInteger myLength = [self length];
    [self raiseBerExceptionForLengthZero:myLength];
    return myLength;
}

- (uint8_t*)berTag
{
    static uint8_t integerTag[] = { BER_INTEGER };
    return integerTag;
}

- (NSData*)berData
{
    NSMutableData *berData = [[NSMutableData  alloc] init];
    [berData appendData:[self berHeader]];
    [berData appendData:self];
    return berData;
}

#pragma mark - NSData Decoding

- (id)berDecode
{
    NSUInteger iterator = 0;
    return [self berDecodeFromStart:0 
                                 to:[self length] - 1
                           iterator:&iterator];
}

- (id)berDecodeFromStart:(NSUInteger)start to:(NSUInteger)end iterator:(NSUInteger*)iterator
{
    uint8_t *bytes = (uint8_t*)[self bytes];
    uint8_t currentTag = bytes[start];
    
    switch (currentTag) 
    {
        case BER_SEQUENCE_CONSTRUCTED:
            return [self berDecodeAsArrayFrom:start to:end];
            break;
        case BER_SET_CONSTRUCTED:
            return [self berDecodeAsSetFrom:start to:end];
            break;
        case BER_INTEGER:
            return [self berDecodeAsDataFrom:start to:end];
            break;
        case BER_UTF8STRING:
            return [self berDecodeAsStringFrom:start to:end];
            break;
        case BER_A0:
        case BER_BIT_STRING:
        case BER_OBJECT_IDENTIFIER:
            return [self berDecodeAsDataTagged:currentTag 
                                          from:start 
                                            to:end];
            break;
        case BER_IA5STRING:
        case BER_UTCTIME:
            return [self berDecodeAsStringTagged:currentTag 
                                            from:start 
                                              to:end];
            break;
        case BER_NULL:
            return [NSNull null];
            *iterator += 1;
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

- (NSMutableArray*)berDecodeAsArrayFrom:(NSUInteger)start to:(NSUInteger)end
{
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
    return [self berDecodeAsCollection:newArray from:start to:end];
}

- (NSMutableSet*)berDecodeAsSetFrom:(NSUInteger)start to:(NSUInteger)end
{
    BerTaggedCollection *newSet = [[BerTaggedCollection alloc] init];
    newSet.berTagValue = (BER_SET | kBerTypeConstructed);
    newSet.collection = [[NSMutableArray alloc] init];
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
    BerTaggedString *newIA5String = [[BerTaggedString alloc] init];
    newIA5String.string = [self berDecodeAsStringFrom:start to:end];
    newIA5String.berTagValue = tagValue;
    return newIA5String;
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

- (NSData*)berData
{
    NSMutableData *berData = [[NSMutableData  alloc] init];
    [berData appendData:[self berHeader]];
    for (NSUInteger i = 0; i < [self count]; i++) {
        [berData appendData:[[self objectAtIndex:i] berData]];
    }
    return berData;
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
