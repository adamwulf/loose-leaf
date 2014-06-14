//
//  MMDrawingTouchGestureRecognizer.h
//  LooseLeaf
//
//  Created by Adam Wulf on 2/8/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMCancelableGestureRecognizer.h"
#import "MMGestureTouchOwnershipDelegate.h"

@interface MMDrawingTouchGestureRecognizer : MMCancelableGestureRecognizer{
    NSMutableSet* ignoredTouches;
    NSMutableOrderedSet* possibleTouches;
    NSMutableOrderedSet* validTouches;
    
    __weak NSObject<MMGestureTouchOwnershipDelegate>* touchDelegate;
}

@property (nonatomic, weak) NSObject<MMGestureTouchOwnershipDelegate>* touchDelegate;
@property (readonly) NSArray* validTouches;

+(MMDrawingTouchGestureRecognizer*) sharedInstace;

-(void) ownershipOfTouches:(NSSet*)touches isGesture:(UIGestureRecognizer*)gesture;

@end
