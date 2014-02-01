//
//  iOS_TrelloTests.m
//  iOS TrelloTests
//
//  Created by Joseph Chen on 1/26/14.
//  Copyright (c) 2014 Joseph Chen. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <RestKit/RestKit.h>
#import "TRConfigs.h"
#import "TRMapBuilder.h"

@interface iOS_TrelloTests : XCTestCase

@end

@implementation iOS_TrelloTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testMapBuilder
{
    RKObjectManager *objectManager = [RKObjectManager al]
    TRMapBuilder *mapBuilder = [[TRMapBuilder alloc] initWithFile:MAPPING_DEFINITIONS_FILENAME
                                                    objectManager:<#(RKObjectManager *)#>]
}

@end
