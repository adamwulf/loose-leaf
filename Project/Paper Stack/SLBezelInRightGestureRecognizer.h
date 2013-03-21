//
//  SLBezelInRightGestureRecognizer.h
//  scratchpaper
//
//  Created by Adam Wulf on 6/24/12.
//
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "Constants.h"

@interface SLBezelInRightGestureRecognizer : UIGestureRecognizer{
    // direction the user is panning
    SLBezelPanDirection panDirection;
    // use to calculate direction
    CGPoint lastKnownLocation;
    // use to calculate translation
    CGPoint firstKnownLocation;
    
    NSMutableSet* validTouches;

    NSDate* dateOfLastBezelEnding;
    NSInteger numberOfRepeatingBezels;
}

@property (nonatomic, readonly) SLBezelPanDirection panDirection;
@property (nonatomic, readonly) NSInteger numberOfRepeatingBezels;

-(CGPoint) translationInView:(UIView*)view;

-(void) resetPageCount;

@end
