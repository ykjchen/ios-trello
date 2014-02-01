ios-trello
==========

This project is an iOS wrapper for the [Trello API](https://trello.com/docs/index.html).

ARC and non-ARC are/will be supported.

### Add to your project

#### Drag into your project
##### Libraries
1. RestKit: `libRestKit.a`  
2. GTMOAuth: `libOAuthTouch.a` // this was modified to conform to the Trello API

##### Source
1. ios-trello directory: `IOSTrello`

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


