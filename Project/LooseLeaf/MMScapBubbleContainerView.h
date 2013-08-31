//
//  MMScapBubbleContainerView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/31/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMScrapContainerView.h"
#import "MMScrapView.h"


@interface MMScapBubbleContainerView : MMScrapContainerView

-(void) addScrapAnimated:(MMScrapView*)scrap;

-(void) didUpdateAccelerometerWithReading:(CGFloat)currentRawReading;

@end
