//
//  TRMemberMethods.h
//  iOS Trello
//
//  Created by Joseph Chen on 2/1/14.
//  Copyright (c) 2014 Joseph Chen. All rights reserved.
//

/*!
 * These methods are included here as categories
 * so that they are not overwritten when the model
 * is updated.
 */

#import "TRMember.h"

@interface TRMember (CustomMethods)

+ (TRMember *)localMember;
+ (void)clearLocalMember;
+ (void)getLocalMemberWithSuccess:(void (^)(TRMember *member))success
                          failure:(void (^)(NSError *error))failure;

+ (TRMember *)memberWithId:(NSString *)identifier;
+ (void)getMemberWithId:(NSString *)identifier
                success:(void (^)(TRMember *member))success
                failure:(void (^)(NSError *error))failure;

@end
