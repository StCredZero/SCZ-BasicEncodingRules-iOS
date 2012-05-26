//
//  Unit_Tests.m
//  Unit Tests
//
//  Created by Peter Suk on 5/23/12.
//  Copyright (c) 2012 Ooghamist LLC. All rights reserved.
//

#import "Unit_Tests.h"

@implementation Unit_Tests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (NSData*)dataWithDEADBEEFLength:(NSUInteger)length
{
    uint8_t item_bytes[] = { 0xDE, 0xAD, 0xBE, 0xEF };
    NSMutableData *returnValue = [[NSMutableData alloc] initWithLength:length];
    uint8_t *bytes = [returnValue mutableBytes];
    for (NSUInteger i = 0; i < length; i++)
    {
        bytes[i] = item_bytes[i % 4];
    }
    return returnValue;
}

- (NSData*)dataWithCAFEBABELength:(NSUInteger)length
{
    uint8_t item_bytes[] = { 0xCA, 0xFE, 0xBA, 0xBE };
    NSMutableData *returnValue = [[NSMutableData alloc] initWithLength:length];
    uint8_t *bytes = [returnValue mutableBytes];
    for (NSUInteger i = 0; i < length; i++)
    {
        bytes[i] = item_bytes[i % 4];
    }
    return returnValue;
}

- (NSString*)hexadecimalFor:(NSData*)data
{
    NSMutableString *result = [[NSMutableString alloc] init];
    uint8_t *resultBytes = (uint8_t*)[data bytes];
    for (NSUInteger i = 0; i < [data length]; i++)
    {
        [result appendFormat:@"%02X", resultBytes[i]];
    }
    return result;
}

- (void)testSmallItems
{

    NSData *item1 = [self dataWithDEADBEEFLength:4];
    NSData *item2 = [self dataWithCAFEBABELength:4];
    
    NSMutableArray *testArray = [[NSMutableArray alloc] init];
    [testArray addObject:item1];
    [testArray addObject:item2];
    NSData *testData = [testArray berData];

    
    NSLog(@"testData: %@", [self hexadecimalFor:testData]);
    
    NSMutableArray *testArray2 = [testData berDecode];
    
    STAssertEqualObjects(testArray, testArray2,
                   @"Small items failed");
    
    NSData *testData2 = [testArray2 berData];
    
    NSLog(@"testData: %@", [self hexadecimalFor:testData2]);

}

- (void)testBigItems
{
    
    NSData *item1 = [self dataWithDEADBEEFLength:0x7F];
    NSData *item2 = [self dataWithCAFEBABELength:500];
    
    NSMutableArray *testArray = [[NSMutableArray alloc] init];
    [testArray addObject:item1];
    [testArray addObject:item2];
    NSData *testData = [testArray berData];
        
    NSMutableArray *testArray2 = [testData berDecode];
    
    STAssertEqualObjects(testArray, testArray2,
                         @"Big items decode failed");
    
    NSData *testData2 = [testArray2 berData];
    
    STAssertEqualObjects(testData, testData2,
                         @"Big items failed");
}

- (void)testNestedArrays
{
    
    NSData *item1 = [self dataWithDEADBEEFLength:0x7F];
    NSData *item2 = [self dataWithCAFEBABELength:500];
    
    NSMutableArray *testArray = [[NSMutableArray alloc] init];
    NSMutableArray *nestedArray = [[NSMutableArray alloc] init];
    [nestedArray addObject:item1];
    [testArray addObject:nestedArray];
    [testArray addObject:item2];
    NSData *testData = [testArray berData];
    
    NSMutableArray *testArray2 = [testData berDecode];
    
    STAssertEqualObjects(testArray, testArray2,
                         @"Nested arrays failed");
    
    NSData *testData2 = [testArray2 berData];
    
    STAssertEqualObjects(testData, testData2,
                         @"Nested arrays data failed");
}

- (void)testCert
{
    char *certBytes = "\x30\x82\x01\xd3\x30\x82\x01\x3c\xa0\x03\x02\x01\x02\x02\x01\x03\x30\x0d\x06\x09\x2a\x86\x48\x86\xf7\x0d\x01\x01\x04\x05\x00\x30\x19\x31\x17\x30\x15\x06\x0a\x09\x92\x26\x89\x93\xf2\x2c\x64\x01\x19\x16\x07\x73\x64\x6d\x64\x65\x6d\x6f\x30\x1e\x17\x0d\x31\x32\x30\x35\x32\x31\x31\x36\x33\x31\x33\x34\x5a\x17\x0d\x31\x37\x30\x35\x32\x31\x31\x36\x33\x31\x33\x34\x5a\x30\x46\x31\x17\x30\x15\x06\x0a\x09\x92\x26\x89\x93\xf2\x2c\x64\x01\x19\x16\x07\x73\x64\x6d\x64\x65\x6d\x6f\x31\x2b\x30\x13\x06\x0a\x09\x92\x26\x89\x93\xf2\x2c\x64\x01\x01\x0c\x05\x61\x64\x6d\x69\x6e\x30\x14\x06\x03\x55\x04\x03\x0c\x0d\x41\x64\x6d\x69\x6e\x69\x73\x74\x72\x61\x74\x6f\x72\x30\x81\x9f\x30\x0d\x06\x09\x2a\x86\x48\x86\xf7\x0d\x01\x01\x01\x05\x00\x03\x81\x8d\x00\x30\x81\x89\x02\x81\x81\x00\xd2\xa2\x25\x1e\x78\x68\x14\xa8\xb4\xcc\xa1\x33\xae\xcd\xfb\xd1\xdf\x22\x5d\xbe\x87\xbc\x4b\x7f\x86\xff\x26\x91\xe3\xee\x74\x13\x98\x85\x73\x05\x24\x81\x03\xa1\x05\x19\x5f\x20\x7e\x16\x0f\xbd\x9f\x35\x82\xfb\x08\x8d\x53\x5d\x91\x99\xe7\xd9\xd7\x8e\x49\xef\xa2\x6f\x14\x63\x81\x6b\xcd\x6a\xdf\x56\x24\x27\xba\xfb\x76\x91\x19\xfa\x74\x41\x34\xad\x23\xee\xd8\xd6\x4a\x40\x69\x88\x67\x1e\xa4\x34\x11\x97\xd7\xc3\x9b\x42\xbd\x15\x69\x29\xf8\x8c\x7e\xd9\x70\xe7\xcd\x40\xc4\x18\x47\x09\x1e\x4d\x35\x73\x49\x95\xd6\xd1\x02\x03\x01\x00\x01\x30\x0d\x06\x09\x2a\x86\x48\x86\xf7\x0d\x01\x01\x04\x05\x00\x03\x81\x81\x00\x79\x18\xab\xf1\xb1\x51\x3b\xb3\x22\xbe\x03\x69\x3e\xc7\x17\x91\xf9\x4d\x79\x0c\xc5\x91\x7e\xc9\xc9\xd9\xd0\x29\x31\x99\x93\x05\x2b\xa2\x74\x5e\x58\xc4\x70\xd3\x36\xa8\xfd\x48\x8e\x4b\xb3\xe3\x5b\xc1\x46\x2e\x54\x08\xd3\xdb\xd4\xa8\x4e\xa7\x5c\xfc\x81\xec\x85\xe1\x0e\xfb\xf4\x0b\xa9\x87\xaa\xb7\x3e\xa5\x88\x3d\x9c\x3e\xe7\x60\xff\xc0\x1c\x36\xa0\xe5\x5a\xa7\x8b\xfe\x0b\x21\xda\xc0\x20\x72\x97\x08\xca\x9e\xd3\x20\x68\xa4\xf1\x0c\x29\xc8\x2e\x92\xff\x8b\x3c\x89\xb2\x78\x23\xf0\xb0\x81\xa3\x9f\x87\x14\x38\xb4";
    //length 471
    NSData *testData = [NSData dataWithBytes:certBytes length:471];
    NSString *testDataBase64 = [testData base64EncodedString];
    NSLog(@"base64: %@", testDataBase64);
    BerTaggedObject *parsed = [testData berParse];
    NSData *testData2 = [parsed berData];
    
    BERPrintVisitor *printer = [[BERPrintVisitor alloc] init];
    [printer visitBERInteriorNode:parsed];
    NSLog(@"result: %@", printer.string);
    STAssertEqualObjects(testData, testData2,
                         @"Cert binaries are not the same");
}

@end
