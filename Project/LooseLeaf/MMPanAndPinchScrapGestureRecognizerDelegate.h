//
//  MMPanAndPinchScrapGestureRecognizerDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/26/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMPanGestureDelegate.h"

@class MMPaperView;

@protocol MMPanAndPinchScrapGestureRecognizerDelegate <MMPanGestureDelegate>

-(NSArray*) scraps;

-(BOOL) panScrapRequiresLongPress;

-(CGFloat) topVisiblePageScaleForScrap:(MMScrapView*)scrap;

-(CGPoint) convertScrapCenterToScrapContainerCoordinate:(MMScrapView*)scrap;

-(BOOL) isAllowedToPan;

-(BOOL) allowsHoldingScrapsWithTouch:(UITouch*)touch;

@end
