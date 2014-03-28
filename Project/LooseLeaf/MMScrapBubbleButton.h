//
//  MMScrapBubbleView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/26/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMScrapView.h"
#import "MMSidebarButton.h"

@interface MMScrapBubbleButton : MMSidebarButton{
    MMScrapView* scrap;
    CGFloat scale;
    CGFloat originalScrapScale;
}

@property (nonatomic) MMScrapView* scrap;
@property (nonatomic, assign) CGFloat rotationAdjustment;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) CGFloat originalScrapScale;

+(CGAffineTransform) idealTransformForScrap:(MMScrapView*)scrap;

@end
