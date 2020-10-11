//
//  MMPaperRequest.m
//  LooseLeaf
//
//  Created by Yih-Chun Hu on 10/11/20.
//  Copyright © 2020 Milestone Made, LLC. All rights reserved.
//

#import "MMPaperRequest.h"
#import "HTTPLogging.h"
#import "HTTPServer.h"
#import "HTTPConnection.h"
#import "HTTPMessage.h"
#import "HTTPResponse.h"
#import "HTTPAuthenticationRequest.h"
#import "HTTPFileResponse.h"
#import "HTTPAsyncFileResponse.h"
#import "MMPageCacheManager.h"

static const int httpLogLevel = HTTP_LOG_LEVEL_WARN;

@implementation MMPaperRequest
- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path;
{
    HTTPLogTrace();

    // Override me to provide custom responses.

    NSString *filePath = [self filePathForURI:path allowDirectory:NO];
    if ([path isEqualToString:@"/"]) {
        if ([MMPageCacheManager sharedInstance].currentEditablePage)
            filePath = [[MMPageCacheManager sharedInstance].currentEditablePage exportAt];
    }
    BOOL isDir = NO;
    if (filePath && [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir] && !isDir) {
        return [[HTTPFileResponse alloc] initWithFilePath:filePath forConnection:self];
     }

     return nil;
}

@end
