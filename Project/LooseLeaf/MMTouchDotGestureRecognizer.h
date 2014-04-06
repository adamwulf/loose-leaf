//
//  MMTouchDotGestureRecognizer.h
//  LooseLeaf
//
//  Created by Adam Wulf on 4/5/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMTouchDotGestureRecognizerDelegate.h"

@interface MMTouchDotGestureRecognizer : UIGestureRecognizer<UIGestureRecognizerDelegate>{
    __weak NSObject<MMTouchDotGestureRecognizerDelegate>* touchDelegate;
}

+(MMTouchDotGestureRecognizer*) sharedInstace;

@property (nonatomic, weak) NSObject<MMTouchDotGestureRecognizerDelegate>* touchDelegate;

@property (readonly) NSSet* activeTouches;

@end
