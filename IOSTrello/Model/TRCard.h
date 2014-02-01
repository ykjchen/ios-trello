//
//  TRCard.h
//  iOS Trello
//
//  Created by Joseph Chen on 2/1/14.
//  Copyright (c) 2014 Joseph Chen. All rights reserved.
//

#import "TRManagedObject.h"

@interface TRCard : TRManagedObject

@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSNumber * closed;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * comments;
@property (nonatomic, retain) NSArray * labels;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * pos;
@property (nonatomic, retain) NSDate * due;
@property (nonatomic, retain) NSManagedObject *list;

@end
