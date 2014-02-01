//
//  TRBoard.h
//  iOS Trello
//
//  Created by Joseph Chen on 1/27/14.
//  Copyright (c) 2014 Joseph Chen. All rights reserved.
//

/*!
 * This models the |board| object in Trello's REST API.
 * The model is incomplete in that it does not contain 
 * all of the properties available in the API.
 */

#import "TRManagedObject.h"

@class TRMember;

@interface TRBoard : TRManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * closed;
@property (nonatomic, retain) NSNumber * pinned;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSSet *members;
@end

@interface TRBoard (CoreDataGeneratedAccessors)

- (void)addMembersObject:(TRMember *)value;
- (void)removeMembersObject:(TRMember *)value;
- (void)addMembers:(NSSet *)values;
- (void)removeMembers:(NSSet *)values;

@end
