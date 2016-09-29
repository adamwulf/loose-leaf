//
//  MMScrapBubbleView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/26/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMScrapView.h"
#import "MMCountBubbleButton.h"


@interface MMScrapBubbleButton : MMCountBubbleButton {
    MMScrapView* scrap;
    CGFloat originalScrapScale;
}

@property (nonatomic) MMScrapView* scrap;
@property (nonatomic, assign) CGFloat rotationAdjustment;
@property (nonatomic, assign) CGFloat originalScrapScale;

+ (CGFloat)idealScaleForScrap:(MMScrapView*)scrap;
+ (CGAffineTransform)idealTransformForScrap:(MMScrapView*)scrap;

@end
