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

- (void)raiseUnimplemented {
    [NSException 
     raise:@"Invalid BER translation" 
     format:@"unimplemented for this type"];
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

@end


@implementation NSData (BasicEncodingRules)

- (NSUInteger)berContentsLengthBytes
{
    NSUInteger myLength = [self length];
    [self raiseBerExceptionForLengthZero:myLength];
    return myLength;
}

- (uint8_t*)berTag
{
    static uint8_t integerTag[] = { 0x02 };
    return integerTag;
}

- (NSData*)berData
{
    NSMutableData *berData = [[NSMutableData  alloc] init];
    [berData appendData:[self berHeader]];
    [berData appendData:self];
    return berData;
}

@end


@implementation NSArray (BasicEncodingRules)

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
    static uint8_t bitfieldTag[] = { 0x30 };
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
