//
//  TRMember.h
//  iOS Trello
//
//  Created by Joseph Chen on 2/1/14.
//  Copyright (c) 2014 Joseph Chen. All rights reserved.
//

#import "TRManagedObject.h"

@class TRBoard;

@interface TRMember : TRManagedObject

@property (nonatomic, retain) NSString * bio;
@property (nonatomic, retain) NSString * fullName;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * initials;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSSet *boards;
@end

@interface TRMember (CoreDataGeneratedAccessors)

- (void)addBoardsObject:(TRBoard *)value;
- (void)removeBoardsObject:(TRBoard *)value;
- (void)addBoards:(NSSet *)values;
- (void)removeBoards:(NSSet *)values;

@end
