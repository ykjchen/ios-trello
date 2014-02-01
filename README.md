ios-trello
==========

iOS wrapper for the Trello API

Other Linker Flags:
-ObjC
-all_load

Link  Binary With Libraries:
MobileCoreServices.framework
CoreData.framework
CFNetwork.framework
SystemConfiguration.framework
Security.framework
CoreGraphics.framework
UIKit.framework
Foundation.framework
libRestKit.a
libOAuthTouch.a // this was modified to conform to the Trello API

Header Search Paths:
$(SRCROOT)/../Libraries/Headers
