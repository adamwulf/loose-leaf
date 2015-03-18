//
//  MMAbstractShareItem.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/10/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMShareItem.h"

@interface MMAbstractShareItem : NSObject<MMShareItem>

-(void) animateCompletionText:(NSString*)linkText withImage:(UIImage*)icon;

@end
