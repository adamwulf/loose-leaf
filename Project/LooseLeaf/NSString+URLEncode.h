//
//  NSString+URLEncode.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/23/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (URLEncode)

- (NSString*)urlEncodedString;

- (NSString*)stringByRemovingWhiteSpace;

@end
