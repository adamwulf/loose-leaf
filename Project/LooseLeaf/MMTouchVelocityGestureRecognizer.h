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

@class MMScrapPaperStackView;

struct DurationCacheObject{
    // hash uniquely identifying a touch,
    // 0 if this record is free to use
    NSUInteger hash;
    // the most recent timestamp of that touch
    NSTimeInterval lastTimestamp;
    // the normalized velocity of the touch
    // from it's most recent movement
    CGFloat instantaneousNormalizedVelocity;
    // the normalized and average velocity
    // of the touch
    CGFloat avgNormalizedVelocity;
    // the direction vector of the touch
    // most recently
    CGPoint directionOfTouch;
    // the angle delta between this direction
    // and the last direction
    CGFloat deltaAngle;
    // most recent distance travelled
    CGFloat distanceFromPrevious;
    // total distance travelled
    CGFloat totalDistance;
};

@interface MMTouchVelocityGestureRecognizer : UIGestureRecognizer<UIGestureRecognizerDelegate>{
    __weak MMScrapPaperStackView* stackView;
}

@property (nonatomic, weak) MMScrapPaperStackView* stackView;

+(MMTouchVelocityGestureRecognizer*) sharedInstace;

+(int) cacheSize;

+(int) maxVelocity;

-(CGFloat) normalizedVelocityForTouch:(UITouch*)touch;

-(struct DurationCacheObject) velocityInformationForTouch:(UITouch*)touch withIndex:(int*)index;

-(int) indexForTouchInCacheIfExists:(UITouch*)touch;

-(int) numberOfActiveTouches;

@end
