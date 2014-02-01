//
//  TRBoard.h
//  iOS Trello
//
//  Created by Joseph Chen on 2/1/14.
//  Copyright (c) 2014 Joseph Chen. All rights reserved.
//

#import "TRManagedObject.h"

@class TRMember;

@interface TRBoard : TRManagedObject

@property (nonatomic, retain) NSNumber * closed;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * pinned;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSSet *members;
@property (nonatomic, retain) NSSet *lists;
@end

@interface TRBoard (CoreDataGeneratedAccessors)

- (void)addMembersObject:(TRMember *)value;
- (void)removeMembersObject:(TRMember *)value;
- (void)addMembers:(NSSet *)values;
- (void)removeMembers:(NSSet *)values;

- (void)addListsObject:(NSManagedObject *)value;
- (void)removeListsObject:(NSManagedObject *)value;
- (void)addLists:(NSSet *)values;
- (void)removeLists:(NSSet *)values;

@end
