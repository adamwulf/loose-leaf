//
//  MMScrapBubbleView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/26/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMScrapView.h"
#import "MMBounceButton.h"

@interface MMScrapBubbleView : MMBounceButton{
    MMScrapView* scrap;
    CGFloat scale;
}

@property (nonatomic) MMScrapView* scrap;
@property (nonatomic, assign) CGFloat rotationAdjustment;
@property (nonatomic, assign) CGFloat scale;

+(CGAffineTransform) idealTransformForScrap:(MMScrapView*)scrap;

@end
