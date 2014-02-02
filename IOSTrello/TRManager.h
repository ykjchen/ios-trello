//
//  TRManager.h
//  iOS Trello
//
//  Created by Joseph Chen on 1/26/14.
//  Copyright (c) 2014 Joseph Chen. All rights reserved.
//

/*!
 * This is a singleton class that provides the main interface
 * for this wrapper. It manages authorization to the user's
 * Trello account via OAuth and manages a RestKit RKObjectManager
 * which is responsible for requests to Trello's servers.
 */

#import <Foundation/Foundation.h>

// helpers, configs, constants
#import "TRHelpers.h"
#import "TRSensitiveConfigs.h"
#import "TRNotifications.h"
#import "TRConfigs.h"

@class TRMember;

@interface TRManager : NSObject

/*!
 * Access the singleton instance of this class.
 */
+ (TRManager *)sharedManager;

/*!
 * Saves the managed object context.
 */
- (void)save;

#pragma mark - Authorization to access user's Trello data

/*!
 * Set |authorizationHandler| to respond to completion of the OAuth process.
 * If the |isAuthorized| parameter is NO, |error| should be non-nil.
 */

/*!
 * Get a view controller to present to the user to get his
 * authorization to access his account.
 */
- (UIViewController *)authorizationViewControllerWithCompletionHandler:(void (^)(BOOL isAuthorized, NSError *error))handler;

/*!
 * Deauthorize the device from accessing the current user's account.
 * (Note that this currently does not remove the application permission token from Trello)
 */
- (void)deauthorize;

/*!
 * Check if the device has access to a user's Trello account.
 */
- (BOOL)isAuthorized;

/*!
 * This returns the authorizationToken required for requests for
 * private objects.
 */
- (NSString *)authorizationToken;

@end
