//
//  MMScapBubbleContainerView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/31/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMScrapContainerView.h"
#import "MMScrapView.h"
#import "MMScapBubbleContainerViewDelegate.h"
#import "MMScrapBezelMenuViewDelegate.h"


@interface MMScapBubbleContainerView : MMScrapContainerView<MMScrapBezelMenuViewDelegate>{
    __weak NSObject<MMScapBubbleContainerViewDelegate>* delegate;
}

@property (nonatomic, weak) NSObject<MMScapBubbleContainerViewDelegate>* delegate;

-(void) addScrapToBezelSidebarAnimated:(MMScrapView*)scrap;

-(void) didUpdateAccelerometerWithRawReading:(CGFloat)currentRawReading andX:(CGFloat)xAccel andY:(CGFloat)yAccel andZ:(CGFloat)zAccel;

-(void) hideMenuIfNeeded;

-(void) animateAndAddScrapBackToPage:(MMScrapView*)scrap;

@end
