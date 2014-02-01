//
//  TRManager.m
//  iOS Trello
//
//  Created by Joseph Chen on 1/26/14.
//  Copyright (c) 2014 Joseph Chen. All rights reserved.
//

#import "TRManager.h"

// frameworks/libraries
#import <RestKit/RestKit.h>
#import <CoreData/CoreData.h>
#import <RestKit/RKManagedObjectStore.h>
#import <GTMOAuth/GTMOAuth.h>

// model
#import "TRManagedObject.h"
#import "TRMember.h"
#import "TRMemberMethods.h"

#import "TRBoard.h"

// helpers
#import "TRMapBuilder.h"

// constants
NSString *const TRAPIServiceName = @"Trello";

@interface TRManager ()

@property (strong, nonatomic) RKObjectManager *objectManager;
@property (strong, nonatomic) GTMOAuthAuthentication *authentication;
@property (strong, nonatomic) NSDictionary *mappings;

@end

static TRManager *_sharedManager = nil;

@implementation TRManager

#pragma mark - Singleton
+ (TRManager *)sharedManager
{
    if (nil != _sharedManager) {
        return _sharedManager;
    }
    
    // www.johnwordsworth.com/2010/04/iphone-code-snippet-the-singleton-pattern
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[super allocWithZone:NULL] init];
    });
    return _sharedManager;
}

// Prevent creation of additional instances
+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedManager];
}

- (id)init
{
    if (_sharedManager) {
        return _sharedManager;
    }
    
    self = [super init];
    
    if (self) {
        [self setUpManagedObjectStore];
    }
    
    return self;
}

#if !__has_feature(objc_arc)
- (id)retain
{
    return self;
}

- (oneway void)release
{
    // Do nothing
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;
}
#endif

#pragma mark - Accessors

- (NSManagedObjectContext *)context
{
    return self.objectManager.managedObjectStore.mainQueueManagedObjectContext;
}

- (RKObjectManager *)objectManager
{
    if (!_objectManager) {
        _objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:API_BASE_URL]];
#if !__has_feature(objc_arc)
        [_objectManager retain];
#endif
    }
    return _objectManager;
}

- (GTMOAuthAuthentication *)authentication
{
    if (!_authentication) {
        GTMOAuthAuthentication *auth = [self defaultAuthentication];
        if (auth) {
            BOOL inKeyChain = [GTMOAuthViewControllerTouch authorizeFromKeychainForName:TRAPIServiceName
                                                                         authentication:auth];
            if (inKeyChain) {
                _authentication = auth;
                
#if !__has_feature(objc_arc)
                [_authentication retain];
#endif
            }
        }
    }
    return _authentication;
}

- (void)removeAuthentication
{
#if !__has_feature(objc_arc)
    [_authentication release];
#endif
    _authentication = nil;
}

#pragma mark - Store Setup

// https://github.com/RestKit/RestKit#configure-core-data-integration-with-the-object-manager
- (void)setUpManagedObjectStore
{
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"TRModel" ofType:@"mom" inDirectory:@"TRModel.momd"];
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    
    NSError *error = nil;
    BOOL success = RKEnsureDirectoryExistsAtPath(RKApplicationDataDirectory(), &error);
    if (! success) {
        RKLogError(@"Failed to create Application Data Directory at path '%@': %@", RKApplicationDataDirectory(), error);
    }
    
    NSString *path = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"Store.sqlite"];
    
#ifdef DEBUG
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
    }
#endif

    NSPersistentStore *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:path fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error];
    if (! persistentStore) {
        RKLogError(@"Failed adding persistent store at path '%@': %@", path, error);
    }
    [managedObjectStore createManagedObjectContexts];
    
    self.objectManager.managedObjectStore = managedObjectStore;
    
    [self mapObjects];
    
#if !__has_feature(objc_arc)
    [managedObjectModel release];
    [managedObjectStore release];
#endif
}

- (void)mapObjects
{
    TRMapBuilder *mapBuilder = [[TRMapBuilder alloc] initWithFile:MAPPING_DEFINITIONS_FILENAME
                                                    objectManager:self.objectManager];
    
    [mapBuilder setBuildHandler:^(BOOL success, NSError *error) {
#if DEBUG
        if (!success) {
            NSLog(@"Could not build mappings: %@", error.localizedDescription);
        }
#endif
    }];
    
#if !__has_feature(objc_arc)
    [mapBuilder release];
#endif
}

#pragma mark - API Requests


#pragma mark - Authorization with GTMOAuth
#pragma mark Public
- (BOOL)isAuthorized
{
    return (self.authentication && [self.authentication canAuthorize]);
}

- (UIViewController *)authorizationViewController
{
    if ([self isAuthorized]) {
        return nil;
    }
    return [self authViewController];
}

- (void)deauthorize
{
    // remove remote authorization data
    
    
    // remove local authorization data
    [GTMOAuthViewControllerTouch removeParamsFromKeychainForName:TRAPIServiceName];
    [self removeAuthentication];
    [TRMember clearLocalMember];
}

- (NSString *)authorizationToken
{
    return self.authentication.token;
}

#pragma mark Private

- (GTMOAuthAuthentication *)defaultAuthentication {
    GTMOAuthAuthentication *auth = [[GTMOAuthAuthentication alloc] initWithSignatureMethod:kGTMOAuthSignatureMethodHMAC_SHA1
                                                                               consumerKey:API_DEVELOPER_KEY
                                                                                privateKey:API_DEVELOPER_SECRET];
#if !__has_feature(objc_arc)
    [auth autorelease];
#endif

    // setting the service name lets us inspect the auth object later to know
    // what service it is for
    auth.serviceProvider = TRAPIServiceName;

    // GTMOAuthAuthentication.h and GTMOAuthAuthentication.m needed to be modified
    // to include the appName property which maps to an "AuthorizeToken extension" @"name".
    // Create custom accessors modeled after those for the domain property.
    // The GTM implementation does not include that parameter, which is required to show the app's name
    // when the OAuth view controller is displayed.
    auth.appName = OAUTH_APP_NAME;

    return auth;
}

- (GTMOAuthViewControllerTouch *)authViewController
{
    NSURL *requestURL = [NSURL URLWithString:OAUTH_REQUEST_URL];
    NSURL *accessURL = [NSURL URLWithString:OAUTH_ACCESS_URL];
    NSURL *authorizeURL = [NSURL URLWithString:OAUTH_AUTHORIZE_URL];
    
    GTMOAuthAuthentication *auth = [self defaultAuthentication];
    
    // set the callback URL to which the site should redirect, and for which
    // the OAuth controller should look to determine when sign-in has
    // finished or been canceled
    //
    // This URL does not need to be for an actual web page
    [auth setCallback:@"http://127.0.0.1:6080/cb"];
    
    // Display the autentication view
    GTMOAuthViewControllerTouch *viewController = [[GTMOAuthViewControllerTouch alloc] initWithScope:OAUTH_SCOPE
                                                                                            language:nil
                                                                                     requestTokenURL:requestURL
                                                                                   authorizeTokenURL:authorizeURL
                                                                                      accessTokenURL:accessURL
                                                                                      authentication:auth
                                                                                      appServiceName:TRAPIServiceName
                                                                                            delegate:self
                                                                                    finishedSelector:@selector(viewController:finishedWithAuth:error:)];
#if !__has_feature(objc_arc)
    [viewController autorelease];
#endif

    return viewController;
}

- (void)viewController:(GTMOAuthViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuthAuthentication *)auth
                 error:(NSError *)error {
    if (error != nil) {
#if DEBUG
        NSLog(@"Authorization failed: %@", error.localizedDescription);
#endif
        
        if (self.authorizationHandler) {
            self.authorizationHandler(NO, error);
        }
    } else {
#if DEBUG
        NSLog(@"Authorization succeeded.");
#endif
        
        [TRMember getLocalMemberWithSuccess:^(TRMember *member) {
            if (self.authorizationHandler) {
                self.authorizationHandler(YES, nil);
            }
        } failure:^(NSError *error) {
            if (self.authorizationHandler) {
                self.authorizationHandler(NO, error);
            }
        }];
    }
}

@end
