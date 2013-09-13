//
//  MMTouchVelocityGestureRecognizer.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/13/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "Constants.h"

@interface MMTouchVelocityGestureRecognizer : UIGestureRecognizer

+(MMTouchVelocityGestureRecognizer*) sharedInstace;

-(CGFloat) normalizedVelocityForTouch:(UITouch*)touch;

@end
