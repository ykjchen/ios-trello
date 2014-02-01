//
//  TRHelpers.m
//  iOS Trello
//
//  Created by Joseph Chen on 2/1/14.
//  Copyright (c) 2014 Joseph Chen. All rights reserved.
//

#import "TRHelpers.h"

// http://stackoverflow.com/questions/17758042/create-custom-variadic-logging-function
void TRFormattedLog(NSString *format, ...) {
    va_list args;
    va_start(args, format);
    NSString *msg = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    NSLog(@"%@", msg);
}
