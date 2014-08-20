//
//  MMOpenInShareItem.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/9/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMShareItem.h"
#import "MMOpenInAppOptionsViewDelegate.h"
#import "MMOpenInAppManagerDelegate.h"

@interface MMOpenInAppShareItem : NSObject<MMShareItem,MMOpenInAppOptionsViewDelegate,MMOpenInAppManagerDelegate>

@end
