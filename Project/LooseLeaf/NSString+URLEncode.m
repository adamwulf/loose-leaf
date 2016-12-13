//
//  NSString+URLEncode.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/23/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "NSString+URLEncode.h"


@implementation NSString (URLEncode)

- (NSString*)urlEncodedString {
    NSMutableString* output = [NSMutableString string];
    const unsigned char* source = (const unsigned char*)[self UTF8String];
    int sourceLen = (int)strlen((const char*)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' ') {
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

- (NSString*)stringByRemovingWhiteSpace {
    return [self stringByReplacingOccurrencesOfString:@"\\s" withString:@""
                                              options:NSRegularExpressionSearch
                                                range:NSMakeRange(0, [self length])];
}

@end
