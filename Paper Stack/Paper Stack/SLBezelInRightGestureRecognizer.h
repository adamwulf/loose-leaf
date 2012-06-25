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
    
    SLBezelPanDirection panDirection;
    CGPoint lastKnownLocation;
    CGPoint firstKnownLocation;
    
    NSMutableSet* ignoredTouches;
    NSMutableSet* validTouches;

    NSDate* dateOfLastBezelEnding;
    NSInteger numberOfRepeatingBezels;
}

@property (nonatomic, readonly) SLBezelPanDirection panDirection;
@property (nonatomic, readonly) NSInteger numberOfRepeatingBezels;

-(CGPoint) translationInView:(UIView*)view;

-(void) resetPageCount;

@end
