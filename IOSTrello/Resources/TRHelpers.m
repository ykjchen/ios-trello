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

NSString *TRPathForFileInDirectory(NSString *fileName, NSSearchPathDirectory nsspd)
{
    NSArray *directories = NSSearchPathForDirectoriesInDomains(nsspd, NSUserDomainMask, YES);
    NSString *directory = [directories objectAtIndex:0];
    
    if (fileName == nil) {
        return directory;
    } else {
        return [directory stringByAppendingPathComponent:fileName];
    }
}

NSString *TRPathInDataDirectory(NSString *fileName)
{
    NSString *libraryDirectory = TRPathForFileInDirectory(nil, NSLibraryDirectory);
    NSString *dataDirectory = [libraryDirectory stringByAppendingPathComponent:@"TRData"];
    BOOL isDir;
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataDirectory isDirectory:&isDir]) {
        NSError *error = nil;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:dataDirectory
                                       withIntermediateDirectories:YES
                                                        attributes:nil
                                                             error:&error]) {
#if DEBUG
            NSLog(@"Error: could not create data directory path (%@)", error.localizedDescription);
#endif
        }
    } else if (!isDir) {
#if DEBUG
        NSLog(@"Error: file at data directory path is not a directory.");
#endif
        return nil;
    }
    
    if (fileName == nil) {
        return dataDirectory;
    } else {
        return [dataDirectory stringByAppendingPathComponent:fileName];
    }
}
