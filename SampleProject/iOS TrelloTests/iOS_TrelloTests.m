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
#import "TRManager.h"

@interface iOS_TrelloTests : XCTestCase

@end

@interface TRManager (Test)

- (RKObjectManager *)objectManager;

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

- (NSArray *)mappingsDefinitions
{
    NSString *path = [[NSBundle mainBundle] pathForResource:[MAPPING_DEFINITIONS_FILENAME stringByDeletingPathExtension] ofType:[MAPPING_DEFINITIONS_FILENAME pathExtension]];
    NSArray *definitions = [NSArray arrayWithContentsOfFile:path];
    return definitions;
}

- (void)testMapBuilder
{
    // Test response descriptors
    NSInteger expectedResponseDescriptors = 1; // Don't forget to count the error descriptor.

    NSArray *mappingDefinitions = [self mappingsDefinitions];
    for (NSDictionary *definition in mappingDefinitions) {
        NSArray *responseDescriptors = definition[@"responseDescriptors"];
        expectedResponseDescriptors += responseDescriptors.count;
    }
    
    NSArray *responseDescriptors = [[[TRManager sharedManager] objectManager] responseDescriptors];
    NSInteger foundResponseDescriptors = [responseDescriptors count];
    XCTAssertEqual(expectedResponseDescriptors, foundResponseDescriptors, @"Response descriptors expected:%i found:%i", expectedResponseDescriptors, foundResponseDescriptors);
}

@end
