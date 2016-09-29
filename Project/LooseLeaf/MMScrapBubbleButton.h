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
#import "MMBubbleButton.h"


@interface MMScrapBubbleButton : MMCountBubbleButton <MMBubbleButton> {
    CGFloat originalScrapScale;
}

@property (nonatomic) MMScrapView* view; // from MMBubbleButton
@property (nonatomic, assign) CGFloat rotationAdjustment;
@property (nonatomic, assign) CGFloat originalScrapScale;

@end
