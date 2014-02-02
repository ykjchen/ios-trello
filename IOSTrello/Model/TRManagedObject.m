//
//  TRManagedObject.m
//  iOS Trello
//
//  Created by Joseph Chen on 2/1/14.
//  Copyright (c) 2014 Joseph Chen. All rights reserved.
//

#import "TRManagedObject.h"

#import "TRSensitiveConfigs.h"
#import <RestKit/RestKit.h>
#import "TRManager.h"

static RKObjectManager *_objectManager = nil;

@implementation TRManagedObject

+ (void)setObjectManager:(RKObjectManager *)objectManager
{
    if (_objectManager == objectManager) {
        return;
    }
    
#if !__has_feature(objc_arc)
    [_objectManager release];
#endif
    
    _objectManager = objectManager;
    
#if !__has_feature(objc_arc)
    [_objectManager retain];
#endif
}

+ (RKObjectManager *)objectManager
{
    return _objectManager;
}

+ (NSManagedObjectContext *)context
{
    return [self objectManager].managedObjectStore.mainQueueManagedObjectContext;
}

+ (NSArray *)fetchObjectsForKey:(NSString *)key
                      predicate:(id)predicate
                 sortDescriptor:(NSString *)sortDescriptor
                  sortAscending:(BOOL)sortAscending
                     fetchLimit:(NSUInteger)fetchLimit
{
    if (![self context]) {
        [NSException raise:@"Set context before performing a fetch." format:nil];
        return nil;
    }
    
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

+ (NSDictionary *)requestParametersForEntity:(NSString *)entityName;
{
    NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:REQUEST_PARAMETERS_FILENAME];
    NSDictionary *parameters = [NSDictionary dictionaryWithContentsOfFile:path];
    return parameters[entityName];
}

+ (NSDictionary *)parametersWithParameters:(NSDictionary *)parameters
{
    NSMutableDictionary *authorizationParameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                    API_DEVELOPER_KEY, @"key",
                                                    [[TRManager sharedManager] authorizationToken], @"token", nil];
    if (parameters) {
        [authorizationParameters addEntriesFromDictionary:parameters];
    }
    return [NSDictionary dictionaryWithDictionary:authorizationParameters];
}

+ (NSDictionary *)defaultGETParameters
{
    return [self parametersWithParameters:[self requestParametersForEntity:[self description]]];
}

- (void)synchronize
{
    
}

- (void)refreshWithSuccess:(void (^)(TRManagedObject *))success
                   failure:(void (^)(NSError *))failure
{
    [[self.class objectManager] getObject:self
                                     path:nil
                               parameters:[self.class defaultGETParameters]
                                  success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                      success([mappingResult firstObject]);
                                  } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                      TRLog(@"Error refreshing: %@", error);
                                      failure(error);
                                  }];
}

@end
