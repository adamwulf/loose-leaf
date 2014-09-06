//
//  CKDisoveredUserInfo.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/31/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "CKDiscoveredUserInfo+Initials.h"

@implementation CKDiscoveredUserInfo (Initials)

-(NSString*) initials{
    NSString* firstLetter = self.firstName.length > 1 ? [self.firstName substringToIndex:1] : @"";
    NSString* lastLetter = self.lastName.length > 1 ? [self.lastName substringToIndex:1] : @"";
    return [firstLetter stringByAppendingString:lastLetter];
}

-(NSDictionary*) asDictionary{
    if(self.userRecordID){
        return @{
                 @"recordId" : self.userRecordID,
                 @"firstName" : self.firstName ? self.firstName : @"",
                 @"lastName" : self.lastName ? self.lastName : @"",
                 @"initials" : self.initials
                 };
    }else{
        return @{};
    }
}

@end
