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
    
    SLBezelDirection bezelDirectionMask;
    SLBezelPanDirection panDirection;
    CGPoint lastKnownLocation;
    CGPoint firstKnownLocation;
    
    NSMutableSet* ignoredTouches;
}

@property (nonatomic, assign) SLBezelDirection bezelDirectionMask;
@property (nonatomic, readonly) SLBezelPanDirection panDirection;

@end
