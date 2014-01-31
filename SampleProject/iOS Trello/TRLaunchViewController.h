//
//  TRLaunchViewController.h
//  iOS Trello
//
//  Created by Joseph Chen on 1/26/14.
//  Copyright (c) 2014 Joseph Chen. All rights reserved.
//

/*!
 * This is the root view controller, showing/responding to the OAuth process.
 */

#import <UIKit/UIKit.h>

@interface TRLaunchViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *authorizationButton;

- (IBAction)tapped:(id)sender;

@end
