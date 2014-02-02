//
//  TRHelpers.h
//  iOS Trello
//
//  Created by Joseph Chen on 2/1/14.
//  Copyright (c) 2014 Joseph Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * This logs only if debugging.
 */
#if DEBUG
#define TRLog(format, ...) TRFormattedLog(@"<%@:%@> %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [NSString stringWithFormat:(format), ##__VA_ARGS__])
#else
#define TRLog(format, ...)
#endif
void TRFormattedLog(NSString *format, ...);

/*!
 * Returns the path of a file in the application data directory.
 */
NSString *TRPathInDataDirectory(NSString *fileName);