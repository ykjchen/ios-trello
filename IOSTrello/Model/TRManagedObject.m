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

- (void)synchronize
{
    
}

@end
