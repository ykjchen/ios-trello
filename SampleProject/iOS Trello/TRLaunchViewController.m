//
//  TRLaunchViewController.m
//  iOS Trello
//
//  Created by Joseph Chen on 1/26/14.
//  Copyright (c) 2014 Joseph Chen. All rights reserved.
//

#import "TRLaunchViewController.h"

// frameworks
#import <QuartzCore/QuartzCore.h>

#import "TRManager.h"
#import "TRMember.h"
#import "TRBoard.h"

@interface TRLaunchViewController ()

@end

@implementation TRLaunchViewController

#if !__has_feature(objc_arc)
- (void)dealloc
{
    [super dealloc];
    [_authorizationButton release];
}
#endif

// Default initializer
- (id)init
{
    self = [super initWithNibName:@"TRLaunchViewController" bundle:nil];
    if (self) {
        // Custom initialization
        [[TRManager sharedManager] setAuthorizationHandler:^(BOOL isAuthorized, NSError *error) {
            if (isAuthorized)
            {
                NSLog(@"Authorized user: %@", [[TRManager sharedManager] localMember]);
            }
            else
            {
                NSLog(@"Failed to authorize user: %@", error.localizedDescription);
                [self hideAuthorizationViewController];
            }
        }];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"TRLaunchViewController";
    self.authorizationButton.layer.cornerRadius = self.authorizationButton.bounds.size.height * 0.25f;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self updateUI];
}

- (void)updateUI
{
    if ([[TRManager sharedManager] isAuthorized]) {
        [self.authorizationButton setTitle:@"Clear Authorization"
                                  forState:UIControlStateNormal];
    } else {
        [self.authorizationButton setTitle:@"Authorize"
                                  forState:UIControlStateNormal];
    }
}

- (void)tapped:(id)sender
{
    if (sender == self.authorizationButton) {
        [self tappedAuthorizationButton];
    }
}

#pragma mark - OAuth

- (void)tappedAuthorizationButton
{
    if ([[TRManager sharedManager] isAuthorized]) {
        [[TRManager sharedManager] deauthorize];
        [self updateUI];
    } else {
        [self showAuthorizationViewController];
    }
}

- (void)showAuthorizationViewController
{
    UIViewController *viewController = [[TRManager sharedManager] authorizationViewController];
    if (viewController) {
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)hideAuthorizationViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
