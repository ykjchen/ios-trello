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
#import "TRSensitiveConfigs.h"
#import "TRNotifications.h"
#import "TRConfigs.h"

@class TRMember;

@interface TRManager : NSObject

/*!
 * Access the singleton instance of this class.
 */
+ (TRManager *)sharedManager;

#pragma mark - Authorization to access user's Trello data
@property (strong, nonatomic) void (^authorizationHandler)(BOOL isAuthorized, NSError *error);
- (UIViewController *)authorizationViewController;
- (void)deauthorize;
- (BOOL)isAuthorized;
- (NSString *)authorizationToken;

@end
