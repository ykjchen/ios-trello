ios-trello
==========

This project is an iOS wrapper for the [Trello REST API](https://trello.com/docs/index.html), making use of [RestKit](http://restkit.org/) and [GTMOAuth](http://code.google.com/p/gtm-oauth/). The interface should be considered unstable as the project is early in development. Currently, only `GET` is supported and only
[`members`](https://trello.com/docs/api/member/index.html), 
[`boards`](https://trello.com/docs/api/board/index.html), 
[`lists`](https://trello.com/docs/api/list/index.html), and 
[`cards`](https://trello.com/docs/api/card/index.html) 
can be requested. The requested objects are mapped to a local Core Data store. A [sample project](https://github.com/ykjchen/ios-trello/tree/master/SampleProject) is included as a demo.

iOS 5+ is supported. ARC and non-ARC are/will be supported.

### Add to your project

#### Drag into your project
##### Libraries (built using iOS SDK 7.0)
1. RestKit: `libRestKit.a` (version 0.22.0)
2. GTMOAuth: `libOAuthTouch.a` (modified to conform to the Trello API)

##### Files
1. ios-trello source directory: [`IOSTrello`](https://github.com/ykjchen/ios-trello/tree/master/IOSTrello)
2. headers for RestKit and GTMOAuth: [`Libraries/Headers`](https://github.com/ykjchen/ios-trello/tree/master/Libraries/Headers)

#### Build Settings
##### Link  Binary With Libraries:
1. `MobileCoreServices.framework`  
2. `CoreData.framework`  
3. `CFNetwork.framework`  
4. `SystemConfiguration.framework`  
5. `Security.framework`  
6. `CoreGraphics.framework`  
7. `UIKit.framework`  
8. `Foundation.framework`  

##### Other Linker Flags:
1. `-ObjC`  
2. `-all_load`  

##### Header Search Paths:
1. The `Headers` directory, e.g. `$(SRCROOT)/../Libraries/Headers`  

### Authorizing the client

1. Log in to [trello.com](https://trello.com) and get a developer key and secret: https://trello.com/1/appKey/generate
2. Enter the key and secret into [`TRSensitiveConfigs.h`](https://github.com/ykjchen/ios-trello/blob/master/IOSTrello/Resources/TRSensitiveConfigs.h).
3. Get a OAuth view controller from the `TRManager` singleton to present to the user to get permission to access his Trello account. At the same time set a completion handler called when authorization completes or fails.

```objective-c        
UIViewController *viewController = [[TRManager sharedManager] authorizationViewControllerWithCompletionHandler:^(BOOL isAuthorized, NSError *error) {
    if (isAuthorized) {
        NSLog(@"Authorized user: %@", [TRMember localMember]);
    } else {
        NSLog(@"Failed to authorize user: %@", error.localizedDescription);
    }
}];

if (viewController) {
    [self.navigationController pushViewController:viewController animated:YES];
}
```
 
##### Other authorization related messages you can send to `[TRManager sharedManager]`:

Deauthorize the device from accessing the current user's account.
(Note that this currently does not remove the application permission token from Trello)

```objective-c
- (void)deauthorize;
```

Check if the device has access to a user's Trello account.
    
```objective-c
- (BOOL)isAuthorized;
```

This returns the token required for API requests for private objects.
    
```objective-c
- (NSString *)authorizationToken;
```

### Requesting Objects

Restkit maps API responses to `NSManagedObject`s. Classes in this wrapper representing Trello objects are subclasses of the abstract superclass `TRManagedObject`, which inherits from `NSManagedObject`. `TRManagedObject` currently has only one public instance method, which retrieves an object and attributes of its children:

```objective-c
- (void)requestDetailsWithSuccess:(void (^)(TRManagedObject *object))success
                          failure:(void (^)(NSError *error))failure;
```

Therefore, objects are accessible only after a parent of that object has been requested. Once the local user is authorized and the local user's `member` object is requested, his `boards` will be accessible. Attributes of each board is requested, but relationships such as a `board`'s `lists` must be requested independently:

To GET details of the local user:

```objective-c
[TRMember getLocalMemberWithSuccess:^(TRMember *member) {
    NSLog(@"GETted local member: %@", member);
} failure:^(NSError *error) {
    NSLog(@"Failed to GET local member: %@", error.localizedDescription);
}];
```

To GET details of the local user's `boards`, `lists`, and `cards`:

```objective-c
// This gets the |member| object corresponding to the local user
TRMember *localMember = [TRMember localMember];

// This gets his boards.
// Only attributes are available unless details had been requested before.
NSSet *boards = localMember.boards;

for (TRBoard *board in boards) {
// NSLog(@"%i", board.lists.count) returns 0.

// This gets the board's lists and their attributes
[board getDetailsWithSuccess:^(TRManagedObject *object) {
    TRBoard *detailedBoard = (TRBoard *)object;
    
    // Now lists of each board are available.
    for (TRList *list in detailedBoard.lists) {
        // NSLog(@"%i", list.cards.count) returns 0.
    
        [list getDetailsWithSuccess:^(TRManagedObject *object) {
            TRList *detailedList = (TRBoard *)object;
            // now attributes of cards in the list are available
        }
                            failure:nil];
    }
}
                     failure:nil]; // Failure is not an option! ;)
}
```

To save the NSManagedObjectContext (persist objects mapped by RestKit):

```objective-c
[[TRManager sharedManager] save];
```

### Extending

Support for other objects, attributes, and relationship can be easily added by modifying:  
1. Core Data model: 
[`TRModel.xcdatamodeld`](https://github.com/ykjchen/ios-trello/tree/master/IOSTrello/Model/TRModel.xcdatamodeld)  

2. RestKit mapping definitions: [`Mappings.plist`](https://github.com/ykjchen/ios-trello/blob/master/IOSTrello/Model/Mappings.plist)  
(See RKEntityMapping for more information)

3. RestKit request parameters: 
[`Parameters.plist`](https://github.com/ykjchen/ios-trello/blob/master/IOSTrello/Model/Parameters.plist)  
(See Trello API for more information)

4. RestKit routing parameters:
[`Routes.plist`](https://github.com/ykjchen/ios-trello/blob/master/IOSTrello/Model/Routes.plist)  
(See RKRoute for more information)

