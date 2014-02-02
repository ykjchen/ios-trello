//
//  TRLaunchViewController.m
//  iOS Trello
//
//  Created by Joseph Chen on 1/26/14.
//  Copyright (c) 2014 Joseph Chen. All rights reserved.
//

#import "TRLaunchViewController.h"

// view controllers
#import "TRResourceViewController.h"

// frameworks
#import <QuartzCore/QuartzCore.h>

// model
#import "TRManager.h"
#import "TRMember.h"
#import "TRMemberMethods.h"
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

// For legacy support
- (void)viewDidUnload
{
    self.authorizationButton = nil;
    
    [super viewDidUnload];
}

// Default initializer
- (id)init
{
    self = [super initWithNibName:@"TRLaunchViewController" bundle:nil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"TRLaunchViewController";
    for (UIButton *button in @[self.authorizationButton, self.localMemberButton]) {
        button.layer.cornerRadius = self.authorizationButton.bounds.size.height * 0.25f;
    }
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
    
    if ([TRMember localMember]) {
        [self.localMemberButton setTitle:@"View Local Member"
                                forState:UIControlStateNormal];
    } else {
        [self.localMemberButton setTitle:@"GET Local Member"
                                forState:UIControlStateNormal];
    }
}

- (void)tapped:(id)sender
{
    if (sender == self.authorizationButton) {
        [self tappedAuthorizationButton];
    } else if (sender == self.localMemberButton) {
        [self tappedLocalMemberButton];
    }
}

- (void)tappedLocalMemberButton
{
    if ([TRMember localMember]) {
        [self viewLocalMember];
    } else {
        [self getLocalMember];
    }
}

- (void)getLocalMember
{
    [TRMember getLocalMemberWithSuccess:^(TRMember *member) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                        message:@"Requested local member. Tap View Local Member for details."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [self updateUI];
        
#if !__has_feature(objc_arc)
        [alert release];
#endif
    } failure:^(NSError *error) {
        NSLog(@"Failed to GET local member: %@", error.localizedDescription);
    }];
}

- (void)viewLocalMember
{
    TRMember *member = [TRMember localMember];
    if (!member) {
        TRLog(@"Local member not found.");
    }
    TRResourceViewController *viewController = [[TRResourceViewController alloc] initWithManagedObject:member];
    [self.navigationController pushViewController:viewController animated:YES];
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
    UIViewController *viewController = [[TRManager sharedManager] authorizationViewControllerWithCompletionHandler:^(BOOL isAuthorized, NSError *error) {
        if (isAuthorized) {
            NSLog(@"Authorized user: %@", [TRMember localMember]);
            [self updateUI];
        } else {
            NSLog(@"Failed to authorize user: %@", error.localizedDescription);
            [self hideAuthorizationViewController];
        }
    }];
    
    if (viewController) {
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)hideAuthorizationViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
