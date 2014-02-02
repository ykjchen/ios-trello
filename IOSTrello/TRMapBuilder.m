//
//  TRMapBuilder.m
//  iOS Trello
//
//  Created by Joseph Chen on 1/27/14.
//  Copyright (c) 2014 Joseph Chen. All rights reserved.
//

#import "TRMapBuilder.h"

#import "TRHelpers.h"
#import <RestKit/RestKit.h>

@interface TRMapBuilder ()

@property (strong, nonatomic) void (^buildHandler)(BOOL success, NSError *error);
@property (strong, nonatomic) RKObjectManager *objectManager;
@property (strong, nonatomic) NSString *mappingDefinitionsFilename;
@property (strong, nonatomic) NSString *routeDefinitionsFilename;
@property (nonatomic, getter = isMappingComplete) BOOL mappingComplete;
@property (strong, nonatomic) NSArray *mappingDefinitions;

@end

@implementation TRMapBuilder

#if !__has_feature(objc_arc)
- (void)dealloc
{
    [super dealloc];

    [_buildHandler release];
    [_objectManager release];
    [_mappingDefinitionsFilename release];
    [_routeDefinitionsFilename release];
    [_mappingDefinitions release];
}
#endif

#pragma mark - Public

- (id)initWithMappingDefinitions:(NSString *)mappingDefinitionsFilename
                routeDefinitions:(NSString *)routeDefinitionsFilename
                   objectManager:(RKObjectManager *)objectManager
{
    if (self = [super init]) {
        _mappingDefinitionsFilename = mappingDefinitionsFilename;
        _routeDefinitionsFilename = routeDefinitionsFilename;
        _objectManager = objectManager;
        
#if !__has_feature(objc_arc)
        [_mappingDefinitionsFilename retain];
        [_routeDefinitionsFilename retain];
        [_objectManager retain];
#endif
    }
    return self;
}

- (void)setBuildHandler:(void (^)(BOOL, NSError *))buildHandler
{
    if (_buildHandler == buildHandler) {
        return;
    }
    
#if !__has_feature(objc_arc)
    [_buildHandler release];
#endif
    _buildHandler = buildHandler;
#if !__has_feature(objc_arc)
    [_buildHandler retain];
#endif
    
    if (buildHandler) {
        if (self.isMappingComplete) {
            buildHandler(YES, nil);
        } else {
            [self startMapping];
        }
    }
}

#pragma mark - Private

- (NSArray *)mappingDefinitions
{
    if (!_mappingDefinitions && self.mappingDefinitionsFilename) {
        NSString *path = [[NSBundle mainBundle] pathForResource:[self.mappingDefinitionsFilename stringByDeletingPathExtension]
                                                         ofType:[self.mappingDefinitionsFilename pathExtension]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            _mappingDefinitions = [[NSArray alloc] initWithContentsOfFile:path];
        }
    }
    return _mappingDefinitions;
}

- (void)startMapping
{
    [self buildErrorMapping];
    
    NSMutableDictionary *mappings = [NSMutableDictionary dictionaryWithCapacity:self.mappingDefinitions.count];
    for (NSDictionary *entityMappingDefinitions in self.mappingDefinitions) {
        NSString *entityName = entityMappingDefinitions[@"entity"];
        NSDictionary *attributes = entityMappingDefinitions[@"attributes"];
        NSArray *identificationAttributes = entityMappingDefinitions[@"identificationAttributes"];
        NSArray *responseDescriptors = entityMappingDefinitions[@"responseDescriptors"];
        NSArray *connectionDescriptions = entityMappingDefinitions[@"connectionDescriptions"];
        
        RKEntityMapping *mapping = [self buildMappingForEntity:entityName attributes:attributes identificationAttributes:identificationAttributes];
        
        [self addResponseDescriptors:responseDescriptors forMapping:mapping];
        [self addConnectionDescriptions:connectionDescriptions forEntity:entityName mapping:mapping];
        
        [mappings setObject:mapping forKey:entityName];
    }
    
    for (NSDictionary *entityMappingDefinitions in self.mappingDefinitions) {
        NSString *entityName = entityMappingDefinitions[@"entity"];
        NSArray *relationships = entityMappingDefinitions[@"relationships"];
        RKEntityMapping *mapping = mappings[entityName];
        if (relationships.count != 0) {
            [self addRelationships:relationships
                 withSourceMapping:mapping
                          mappings:mappings];
        }
    }
    
    [self addRoutes];
    
    [self completedMapping];
}

- (void)addRoutes
{
    NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:self.routeDefinitionsFilename];
    NSDictionary *routes = [NSDictionary dictionaryWithContentsOfFile:path];
    
    for (NSString *key in [routes allKeys]) {
        RKRoute *route = [RKRoute routeWithClass:NSClassFromString(key)
                                     pathPattern:routes[key]
                                          method:RKRequestMethodAny];
        [self.objectManager.router.routeSet addRoute:route];
    }
}

- (void)completedMapping
{
    if (!self.isMappingComplete) {
        self.mappingComplete = YES;
        
        if (self.buildHandler) {
            self.buildHandler(YES, nil);
            self.buildHandler = nil;
        }
    }
}

- (void)addResponseDescriptors:(NSArray *)responseDescriptorInfos forMapping:(RKEntityMapping *)mapping
{
    NSIndexSet *successStatusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful); // Anything in 2xx

    // responseDescriptorInfo has keys @"pathPattern" and @"requestMethod"
    for (NSDictionary *responseDescriptorInfo in responseDescriptorInfos) {
        NSString *pathPattern = responseDescriptorInfo[@"pathPattern"];
        NSString *requestMethod = responseDescriptorInfo[@"requestMethod"];
        NSString *keyPath = responseDescriptorInfo[@"keyPath"];
        
        RKResponseDescriptor *descriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                                                          method:[self requestMethodFromString:requestMethod]
                                                                                     pathPattern:pathPattern
                                                                                         keyPath:keyPath
                                                                                     statusCodes:successStatusCodes];
        [self.objectManager addResponseDescriptor:descriptor];
    }
}

- (void)addRelationships:(NSArray *)relationshipInfos
       withSourceMapping:(RKEntityMapping *)sourceMapping
                mappings:(NSDictionary *)allEntityMappings
{
    for (NSDictionary *relationshipInfo in relationshipInfos) {
        NSString *destinationEntityName = relationshipInfo[@"destinationEntity"];
        NSString *relationship = relationshipInfo[@"relationship"];
        RKEntityMapping *destinationMapping = allEntityMappings[destinationEntityName];
        [sourceMapping addRelationshipMappingWithSourceKeyPath:relationship
                                                       mapping:destinationMapping];
    }
}

- (void)addConnectionDescriptions:(NSArray *)connectionDescriptionInfos forEntity:(NSString *)entityName mapping:(RKEntityMapping *)mapping
{
    if (connectionDescriptionInfos.count == 0) {
        return;
    }
    
    // Relationship Mapping
    NSEntityDescription *memberEntity = [NSEntityDescription entityForName:entityName
                                                    inManagedObjectContext:self.objectManager.managedObjectStore.mainQueueManagedObjectContext];
    
    for (NSDictionary *connectionDescriptionInfo in connectionDescriptionInfos) {
        NSString *relationshipName = connectionDescriptionInfo[@"relationship"];
        NSDictionary *attributes = connectionDescriptionInfo[@"attributes"];
        NSRelationshipDescription *relationshipDescription = [memberEntity relationshipsByName][relationshipName];
        RKConnectionDescription *connection = [[RKConnectionDescription alloc] initWithRelationship:relationshipDescription
                                                                                         attributes:attributes];
        [mapping addConnection:connection];
        
#if !__has_feature(objc_arc)
        [connection release];
#endif
    }
}

- (RKRequestMethod)requestMethodFromString:(NSString *)requestMethodString
{
    if ([requestMethodString isCaseInsensitiveEqualToString:@"GET"]) {
        return RKRequestMethodGET;
    } else if ([requestMethodString isCaseInsensitiveEqualToString:@"POST"]) {
        return RKRequestMethodPOST;
    } else if ([requestMethodString isCaseInsensitiveEqualToString:@"PUT"]) {
        return RKRequestMethodPUT;
    } else if ([requestMethodString isCaseInsensitiveEqualToString:@"DELETE"]) {
        return RKRequestMethodDELETE;
    } else if ([requestMethodString isCaseInsensitiveEqualToString:@"ANY"]) {
        return RKRequestMethodAny;
    }

    [NSException raise:@"Unsupported request method: " format:@"%@", requestMethodString];
    return RKRequestMethodAny;
}

- (RKEntityMapping *)buildMappingForEntity:(NSString *)entityName attributes:(NSDictionary *)attributes identificationAttributes:(NSArray *)identificationAttributes
{
    RKEntityMapping* entityMapping = [RKEntityMapping mappingForEntityForName:entityName
                                                         inManagedObjectStore:self.objectManager.managedObjectStore];
    [entityMapping addAttributeMappingsFromDictionary:attributes];

    entityMapping.identificationAttributes = identificationAttributes;
    
    return entityMapping;
}

// https://github.com/RestKit/RestKit#map-a-client-error-response-to-an-nserror
- (void)buildErrorMapping
{
    // Error Mapping
    // Error JSON looks like {"errors": "Some Error Has Occurred"}
    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[RKErrorMessage class]];
    // The entire value at the source key path containing the errors maps to the message
    [errorMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"errorMessage"]];
    NSIndexSet *errorStatusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError);
    // Any response in the 4xx status code range with an "errors" key path uses this mapping
    RKResponseDescriptor *errorDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping
                                                                                         method:RKRequestMethodAny
                                                                                    pathPattern:nil
                                                                                        keyPath:@"errors"
                                                                                    statusCodes:errorStatusCodes];
    
    // Add our descriptors to the manager
    [self.objectManager addResponseDescriptor:errorDescriptor];
}

@end

@implementation NSString (TRMapBuilder)

- (BOOL)isCaseInsensitiveEqualToString:(NSString *)string
{
    return ([self compare:string options:NSCaseInsensitiveSearch] == NSOrderedSame);
}

@end
