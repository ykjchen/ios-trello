/*!
 * This file contains constants that do not need to
 * but may be altered.
 */

/*!
 * This refers to the file containing mapping definitions for RestKit.
 */
#define MAPPING_DEFINITIONS_FILENAME @"Mappings.plist"

/*!
 * This is the Trello API's base url.
 */
#define API_BASE_URL @"https://api.trello.com/1/"

/*!
 * These are Trello's OAUTH urls.
 */
#define OAUTH_REQUEST_URL @"https://trello.com/1/OAuthGetRequestToken"
#define OAUTH_ACCESS_URL @"https://trello.com/1/OAuthGetAccessToken"
#define OAUTH_AUTHORIZE_URL @"https://trello.com/1/OAuthAuthorizeToken"
#define OAUTH_SCOPE @"read,write"


/*!
 * This is the app name presented during OAuth.
 */
#define OAUTH_LOCALIZED_APP_NAME    [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"]
#define OAUTH_APP_NAME				OAUTH_LOCALIZED_APP_NAME ? OAUTH_LOCALIZED_APP_NAME : [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]