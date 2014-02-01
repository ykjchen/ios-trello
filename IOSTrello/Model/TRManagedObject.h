//
//  TRManagedObject.h
//  iOS Trello
//
//  Created by Joseph Chen on 2/1/14.
//  Copyright (c) 2014 Joseph Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "TRHelpers.h"

@class RKObjectManager;
@interface TRManagedObject : NSManagedObject

/*!
 * Setter for the class' RKObjectManager instance.
 */
+ (void)setObjectManager:(RKObjectManager *)objectManager;

/*!
 * Getter for the class' RKObjectManager instance.
 */
+ (RKObjectManager *)objectManager;

/*!
 * Getter for the class' NSManagedObjectContext instance.
 */
+ (NSManagedObjectContext *)context;

/*!
 * Fetching object from the class' objectManager's store's context.
 */
+ (NSArray *)fetchObjectsForKey:(NSString *)key
                      predicate:(id)predicate
                 sortDescriptor:(NSString *)sortDescriptor
                  sortAscending:(BOOL)sortAscending
                     fetchLimit:(NSUInteger)fetchLimit;

/*!
 * This adds authorization parameters onto the passed in parameters.
 */
+ (NSDictionary *)parametersWithParameters:(NSDictionary *)parameters;

/*!
 * Synchronizes the object with the server.
 */
- (void)synchronize;

@end
