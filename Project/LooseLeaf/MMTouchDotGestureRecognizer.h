//
//  MMTouchDotGestureRecognizer.h
//  LooseLeaf
//
//  Created by Adam Wulf on 4/5/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMTouchDotGestureRecognizer : UIGestureRecognizer<UIGestureRecognizerDelegate>

+(MMTouchDotGestureRecognizer*) sharedInstace;

@property (readonly) NSSet* activeTouches;

@end
