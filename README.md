ios-trello
==========

This project is an iOS wrapper for the [Trello REST API](https://trello.com/docs/index.html), making use of [RestKit](http://restkit.org/) and [GTMOAuth](http://code.google.com/p/gtm-oauth/). The interface should be considered unstable as the project is early in development. Currently, only `members`, `boards`, `lists`, and `cards` can be requested. The requested objects are mapped to a local Core Data store. A [sample project](https://github.com/ykjchen/ios-trello/tree/master/SampleProject) is included as a demo.

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
3. 


