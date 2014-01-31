//
//  TRMapBuilder.h
//  iOS Trello
//
//  Created by Joseph Chen on 1/27/14.
//  Copyright (c) 2014 Joseph Chen. All rights reserved.
//

/*!
 * An instance of this class is used to build the mapping and relationship
 * definitions required by the RestKit RKObjectManager. The mappings and relationships
 * can be configured through the Mappings.plist file in the bundle.
 *
 * See https://github.com/RestKit/RestKit/wiki/Object-mapping for more information
 * on mapping in RestKit.
 */

#import <Foundation/Foundation.h>

@class RKObjectManager;
@interface TRMapBuilder : NSObject

- (id)initWithFile:(NSString *)mappingDefinitionsFilename
     objectManager:(RKObjectManager *)objectManager;
- (void)setBuildHandler:(void (^)(BOOL success, NSError *error))buildHandler;

@end

@interface NSString (TRMapBuilder)

- (BOOL)isCaseInsensitiveEqualToString:(NSString *)string;

@end