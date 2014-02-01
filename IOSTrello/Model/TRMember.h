//
//  TRMember.h
//  iOS Trello
//
//  Created by Joseph Chen on 1/27/14.
//  Copyright (c) 2014 Joseph Chen. All rights reserved.
//

/*!
 * This models the |member| object in Trello's REST API.
 * The model is incomplete in that it does not contain
 * all of the properties available in the API.
 */

#import "TRManagedObject.h"

@class TRBoard;

@interface TRMember : TRManagedObject

@property (nonatomic, retain) NSString * bio;
@property (nonatomic, retain) NSString * fullName;
@property (nonatomic, retain) NSString * initials;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSSet *boards;
@end

@interface TRMember (CoreDataGeneratedAccessors)

- (void)addBoardsObject:(TRBoard *)value;
- (void)removeBoardsObject:(TRBoard *)value;
- (void)addBoards:(NSSet *)values;
- (void)removeBoards:(NSSet *)values;

@end
