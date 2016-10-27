//
//  MMPalmGestureRecognizer.h
//  LooseLeaf
//
//  Created by Adam Wulf on 4/29/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMGestureTouchOwnershipDelegate.h"


@interface MMPalmGestureRecognizer : UIGestureRecognizer

+ (MMPalmGestureRecognizer*)sharedInstance;

@property (nonatomic, unsafe_unretained) NSObject<MMGestureTouchOwnershipDelegate>* panDelegate;
@property (nonatomic, readonly) BOOL hasSeenPalmDuringTouchSession;

@end
