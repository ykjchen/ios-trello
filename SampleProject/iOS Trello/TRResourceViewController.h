//
//  TRResourceViewController.h
//  iOS Trello
//
//  Created by Joseph Chen on 2/2/14.
//  Copyright (c) 2014 Joseph Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TRManagedObject;

@interface TRResourceViewController : UITableViewController

/*!
 * Default initializer
 */
- (id)initWithManagedObject:(TRManagedObject *)managedObject;

@end

@interface TRResourceTableSection : NSObject

@property (nonatomic, getter = isRelationship) BOOL relationship;
@property (strong, nonatomic) NSString *relationshipName;
@property (strong, nonatomic) NSString *sectionName;
@property (strong, nonatomic) NSArray *objects;
@property (strong, nonatomic) NSString *titleKeyPath;

@end