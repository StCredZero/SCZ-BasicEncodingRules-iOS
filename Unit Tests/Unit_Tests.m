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

@end
