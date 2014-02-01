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
#import "TRMember.h"
#import "TRBoard.h"

// helpers
#import "TRMapBuilder.h"

// constants
NSString *const TRAPIServiceName = @"Trello";
NSString *const TRUserDefaultLocalMemberUsername = @"LocalUser";

@interface TRManager () {
    TRMember *_localMember;
}

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
            }
        }
    }
    return _authentication;
}

- (void)removeAuthentication
{
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
}

#pragma mark - Fetching From Store

- (NSArray *)fetchObjectsForKey:(NSString *)key
                      predicate:(id)predicate
                 sortDescriptor:(NSString *)sortDescriptor
                  sortAscending:(BOOL)sortAscending
                     fetchLimit:(NSUInteger)fetchLimit
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:key];
    
    if (predicate != nil) {
        if ([predicate isKindOfClass:[NSString class]]) {
            NSPredicate *pred = [NSPredicate predicateWithFormat:predicate];
            [request setPredicate:pred];
        } else if ([predicate isKindOfClass:[NSPredicate class]]) {
            [request setPredicate:predicate];
        }
    }
    
    if (sortDescriptor != nil) {
        NSSortDescriptor *sd = [NSSortDescriptor
                                sortDescriptorWithKey:sortDescriptor
                                ascending:sortAscending];
        [request setSortDescriptors:[NSArray arrayWithObject:sd]];
    }
    
    [request setFetchLimit:fetchLimit];
    
    NSError *error;
    NSManagedObjectContext *context = [self context];
    NSArray *result = [context executeFetchRequest:request error:&error];
    
#if DEBUG
    if (!result) {
        [NSException raise:@"Fetch failed"
                    format:@"Reason: %@", [error localizedDescription]];
    }
#endif
    
    return result;
}

#pragma mark - API Url Generation

/*!
 * This adds authorization parameters onto the passed in parameters.
 */
- (NSDictionary *)parametersWithParameters:(NSDictionary *)parameters
{
    NSMutableDictionary *authorizationParameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                    API_DEVELOPER_KEY, @"key",
                                                    self.authentication.token, @"token", nil];
    if (parameters) {
        [authorizationParameters addEntriesFromDictionary:parameters];
    }
    return [NSDictionary dictionaryWithDictionary:authorizationParameters];
}

- (NSURL *)urlWithPath:(NSString *)path parameters:(NSDictionary *)parameters
{
    NSMutableString *fullPath = [NSMutableString stringWithString:[API_BASE_URL stringByAppendingPathComponent:path]];
    [fullPath appendFormat:@"?%@", [self authorizationParameters]];
    
    if (parameters) {
        [fullPath appendFormat:@"&%@", [self stringFromParameters:parameters]];
    }
    
    return [NSURL URLWithString:fullPath];
}

- (NSString *)authorizationParameters
{
    return [NSString stringWithFormat:@"key=%@&token=%@", API_DEVELOPER_KEY, self.authentication.token];
}

- (NSString *)stringFromParameters:(NSDictionary *)parameters
{
    NSArray *keys = [parameters allKeys];
    NSMutableArray *formattedParameters = [NSMutableArray arrayWithCapacity:keys.count];
    for (NSString *key in keys) {
        [formattedParameters addObject:[NSString stringWithFormat:@"%@=%@", key, parameters[key]]];
    }
    return [formattedParameters componentsJoinedByString:@"&"];
}

#pragma mark - The Local Member

- (void)setLocalMember:(TRMember *)localMember
{
    if (_localMember == localMember) {
        return;
    }
    _localMember = localMember;
}

- (TRMember *)localMember
{
    if (!_localMember) {
        NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:TRUserDefaultLocalMemberUsername];
        if (!username) {
            return nil;
        }
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username = %@", username];
        NSArray *hits = [self fetchObjectsForKey:@"TRMember"
                                       predicate:predicate
                                  sortDescriptor:nil
                                   sortAscending:NO
                                      fetchLimit:1];
        if (hits.count == 0) {
            return nil;
        }
        
        _localMember = hits[0];
    }
    return _localMember;
}

- (void)getLocalMember
{
    [self.objectManager getObject:nil
                             path:@"members/me"
                       parameters:[self parametersWithParameters:nil]
                          success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
                              TRMember *member = [result firstObject];
                              self.localMember = member;
                              
                              if (self.authorizationHandler) {
                                  self.authorizationHandler(YES, nil);
                              }
                          }
                          failure:^(RKObjectRequestOperation *operation, NSError *error) {
#if DEBUG
                              NSLog(@"-getLocalMember failed with error: %@", [error localizedDescription]);
#endif
                              if (self.authorizationHandler) {
                                  self.authorizationHandler(NO, error);
                              }
                          }];
}

#pragma mark - GTMOAuth
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
    [GTMOAuthViewControllerTouch removeParamsFromKeychainForName:TRAPIServiceName];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:TRUserDefaultLocalMemberUsername];
    [self removeAuthentication];
    [self setLocalMember:nil];
}

#pragma mark Private

- (GTMOAuthAuthentication *)defaultAuthentication {
    GTMOAuthAuthentication *auth = [[GTMOAuthAuthentication alloc] initWithSignatureMethod:kGTMOAuthSignatureMethodHMAC_SHA1
                                                                               consumerKey:API_DEVELOPER_KEY
                                                                                privateKey:API_DEVELOPER_SECRET];

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
    NSURL *requestURL = [NSURL URLWithString:@"https://trello.com/1/OAuthGetRequestToken"];
    NSURL *accessURL = [NSURL URLWithString:@"https://trello.com/1/OAuthGetAccessToken"];
    NSURL *authorizeURL = [NSURL URLWithString:@"https://trello.com/1/OAuthAuthorizeToken"];
    NSString *scope = @"read,write";
    
    GTMOAuthAuthentication *auth = [self defaultAuthentication];
    
    // set the callback URL to which the site should redirect, and for which
    // the OAuth controller should look to determine when sign-in has
    // finished or been canceled
    //
    // This URL does not need to be for an actual web page
    [auth setCallback:@"http://127.0.0.1:6080/cb"];
    
    // Display the autentication view
    GTMOAuthViewControllerTouch *viewController = [[GTMOAuthViewControllerTouch alloc] initWithScope:scope
                                                                                            language:nil
                                                                                     requestTokenURL:requestURL
                                                                                   authorizeTokenURL:authorizeURL
                                                                                      accessTokenURL:accessURL
                                                                                      authentication:auth
                                                                                      appServiceName:TRAPIServiceName
                                                                                            delegate:self
                                                                                    finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    return viewController;
}

- (void)viewController:(GTMOAuthViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuthAuthentication *)auth
                 error:(NSError *)error {
    if (error != nil) {
        // Authorization failed
#if DEBUG
        NSLog(@"Authorization failed: %@", error.localizedDescription);
#endif
        if (self.authorizationHandler) {
            self.authorizationHandler(NO, error);
        }
    } else {
        // Authorization succeeded
#if DEBUG
        NSLog(@"Authorization succeeded.");
#endif
        [self getLocalMember];
    }
}

@end
