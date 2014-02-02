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
 * Refreshes object by re-requesting it.
 */
- (void)getDetailsWithSuccess:(void (^)(TRManagedObject *object))success
                          failure:(void (^)(NSError *error))failure;

@end
