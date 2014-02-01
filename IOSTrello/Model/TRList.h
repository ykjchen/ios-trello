//
//  TRList.h
//  iOS Trello
//
//  Created by Joseph Chen on 2/1/14.
//  Copyright (c) 2014 Joseph Chen. All rights reserved.
//

#import "TRManagedObject.h"

@class TRBoard, TRCard;

@interface TRList : TRManagedObject

@property (nonatomic, retain) NSNumber * closed;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * pos;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) TRBoard *board;
@property (nonatomic, retain) NSSet *cards;
@end

@interface TRList (CoreDataGeneratedAccessors)

- (void)addCardsObject:(TRCard *)value;
- (void)removeCardsObject:(TRCard *)value;
- (void)addCards:(NSSet *)values;
- (void)removeCards:(NSSet *)values;

@end
