//
//  CKDisoveredUserInfo.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/31/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "SPRMessage+Initials.h"


@implementation SPRMessage (Initials)

- (NSString*)initials {
    NSString* firstLetter = self.senderFirstName.length > 1 ? [self.senderFirstName substringToIndex:1] : @"";
    NSString* lastLetter = self.senderLastName.length > 1 ? [self.senderLastName substringToIndex:1] : @"";
    return [[firstLetter stringByAppendingString:lastLetter] uppercaseString];
}

@end
