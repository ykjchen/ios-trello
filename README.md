ios-trello
==========

This project is an iOS wrapper for the [Trello REST API](https://trello.com/docs/index.html), making good use of [RestKit](http://restkit.org/). The interface should be considered unstable as the project is early in development. Currently, only `members`, `boards`, `lists`, and `cards` can be requested. The requested objects are mapped to a local Core Data store. A sample project is included as a demo.

iOS 5+ is supported. ARC and non-ARC are/will be supported.

### Add to your project

#### Drag into your project
##### Libraries
1. RestKit: `libRestKit.a`  
2. GTMOAuth: `libOAuthTouch.a` // this was modified to conform to the Trello API

##### Source
1. ios-trello directory: `IOSTrello`
2. headers for RestKit and GTMOAuth: `Libraries/Headers`

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
2. 


