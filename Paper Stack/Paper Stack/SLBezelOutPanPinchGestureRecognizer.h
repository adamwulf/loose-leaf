//
//  SLBezelOutPanPinchGestureRecognizer.h
//  Paper Stack
//
//  Created by Adam Wulf on 6/19/12.
//  Copyright (c) 2012 Visere. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLPanAndPinchGestureRecognizer.h"
#import "Constants.h"

@interface SLBezelOutPanPinchGestureRecognizer : SLPanAndPinchGestureRecognizer{
    SLBezelDirection bezelDirectionMask;
    NSMutableSet* setOfTouchesThatExitedTheBezel;
    SLBezelDirection didExitToBezel;
}

@property (nonatomic, assign) SLBezelDirection bezelDirectionMask;
@property (nonatomic, readonly) SLBezelDirection didExitToBezel;


@end
