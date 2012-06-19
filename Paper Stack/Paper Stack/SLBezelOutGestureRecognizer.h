//
//  SLBezelOutGestureRecognizer.h
//  Paper Stack
//
//  Created by Adam Wulf on 6/19/12.
//  Copyright (c) 2012 Visere. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "Constants.h"
#import "NSMutableSet+Extras.h"

@interface SLBezelOutGestureRecognizer : UIGestureRecognizer{
    
    SLBezelDirection bezelDirectionMask;
    
    NSMutableSet* knownTouches;
    NSMutableSet* validTouches;
    NSMutableSet* validatedEndedTouches;

}

@property (nonatomic, assign) SLBezelDirection bezelDirectionMask;

@end
