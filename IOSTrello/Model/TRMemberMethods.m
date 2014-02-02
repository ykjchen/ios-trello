//
//  TRMemberMethods.m
//  iOS Trello
//
//  Created by Joseph Chen on 2/1/14.
//  Copyright (c) 2014 Joseph Chen. All rights reserved.
//

#import "TRMemberMethods.h"
#import "TRManagedObjectSubclass.h"

#import <RestKit/RestKit.h>
#import "TRConfigs.h"

// constants
NSString *const TRUserDefaultLocalMemberId = @"LocalMemberId";

// class variables
static TRMember *_localMember = nil;
static NSDictionary *_requestParameters = nil;

@implementation TRMember (CustomMethods)

+ (TRMember *)localMember
{
    if (!_localMember) {
        NSString *identifier = [[NSUserDefaults standardUserDefaults] stringForKey:TRUserDefaultLocalMemberId];
        TRMember *member = [self memberWithId:identifier];
        
        if (member) {
            _localMember = member;
            
#if !__has_feature(objc_arc)
            [_localMember retain];
#endif
        } else {
            TRLog(@"Local member with identifer not found: %@", identifier);
        }
    }
    return _localMember;
}

+ (void)setLocalMember:(TRMember *)member
{
#if !__has_feature(objc_arc)
    [_localMember release];
#endif
    
    _localMember = member;
    
#if !__has_feature(objc_arc)
    [_localMember retain];
#endif
    
    [[NSUserDefaults standardUserDefaults] setObject:member.identifier
                                              forKey:TRUserDefaultLocalMemberId];
}

+ (void)clearLocalMember
{
#if !__has_feature(objc_arc)
    [_localMember release];
#endif
    
    _localMember = nil;
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:TRUserDefaultLocalMemberId];
}

+ (TRMember *)memberWithId:(NSString *)identifier
{
    if (!identifier) {
        return nil;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@", identifier];
    return [self memberWithPredicate:predicate];
}

+ (TRMember *)memberWithPredicate:(NSPredicate *)predicate
{
    NSArray *hits = [self fetchObjectsForKey:@"TRMember"
                                   predicate:predicate
                              sortDescriptor:nil
                               sortAscending:NO
                                  fetchLimit:1];
    if (hits.count == 0) {
        return nil;
    }
    return hits[0];
}

#pragma mark - Requesting

+ (void)getLocalMemberWithSuccess:(void (^)(TRMember *))success
                          failure:(void (^)(NSError *))failure
{
    NSAssert([self objectManager], @"Class' objectManager not set.");
    
    [[self objectManager] getObject:nil
                             path:@"members/me"
                       parameters:[self defaultGETParameters]
                          success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                              TRMember *member = [mappingResult firstObject];
                              [self setLocalMember:member];
                              success(member);
                          }
                          failure:^(RKObjectRequestOperation *operation, NSError *error) {
                              TRLog(@"-getLocalMember failure: %@", error.localizedDescription);
                              failure(error);
                          }];
}

+ (void)getMemberWithId:(NSString *)identifier success:(void (^)(TRMember *))success failure:(void (^)(NSError *))failure
{
    NSAssert([self objectManager], @"Class' objectManager not set.");

    NSString *path = [NSString stringWithFormat:@"members/%@", identifier];
    [[self objectManager] getObject:nil
                               path:path
                         parameters:[self defaultGETParameters]
                            success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                success([mappingResult firstObject]);
                            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                failure(error);
                            }];
}

@end
