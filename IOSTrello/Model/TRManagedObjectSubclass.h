//
//  TRManagedObjectSubclass.h
//  iOS Trello
//
//  Created by Joseph Chen on 2/2/14.
//  Copyright (c) 2014 Joseph Chen. All rights reserved.
//

/*!
 * This file should be imported by subclasses of TRManagedObject to reveal
 * non-public API.
 */

#import "TRManagedObject.h"

@interface TRManagedObject (SubclassingHooks)

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
 * Default parameters for an HTTP request.
 */
+ (NSDictionary *)defaultGETParameters;

/*!
 * Synchronizes the object with the server.
 */
- (void)synchronize;

/*!
 * Get all objects of this Entity.
 */
+ (NSArray *)allObjects;

@end
