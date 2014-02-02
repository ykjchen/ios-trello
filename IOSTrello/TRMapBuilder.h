//
//  TRMapBuilder.h
//  iOS Trello
//
//  Created by Joseph Chen on 1/27/14.
//  Copyright (c) 2014 Joseph Chen. All rights reserved.
//

/*!
 * An instance of this class is used to build the mapping and relationship
 * definitions required by a RestKit RKObjectManager. The mappings and relationships
 * can be configured through the Mappings.plist file in the bundle.
 *
 * See https://github.com/RestKit/RestKit/wiki/Object-mapping for more information
 * on mapping in RestKit.
 */

#import <Foundation/Foundation.h>

@class RKObjectManager;
@interface TRMapBuilder : NSObject

/*!
 * Default initializer.
 * Pass in the filename of the mapping definition plist and
 * the RKObjectManager instance to which mappings should be added.
 */
- (id)initWithMappingDefinitions:(NSString *)mappingDefinitionsFilename
                routeDefinitions:(NSString *)routeDefinitionsFilename
                   objectManager:(RKObjectManager *)objectManager;

/*!
 * Set the build completion handler to start mapping.
 * The |success| parameter of the block is YES if mapping completed without error.
 * If an error occured, the |success| parameter will be NO, and |error| will be non-nil.
 */
- (void)setBuildHandler:(void (^)(BOOL success, NSError *error))buildHandler;

@end

@interface NSString (TRMapBuilder)

/*!
 * Like -isEqualToString: but case-insensitive.
 */
- (BOOL)isCaseInsensitiveEqualToString:(NSString *)string;

@end