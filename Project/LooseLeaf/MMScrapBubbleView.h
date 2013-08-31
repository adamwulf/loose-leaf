//
//  MMScrapBubbleView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/26/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMScrapView.h"

@interface MMScrapBubbleView : UIView{
    MMScrapView* scrap;
    CGFloat rotation;
    CGFloat scale;
}

@property (nonatomic) MMScrapView* scrap;
@property (nonatomic, assign) CGFloat rotation;
@property (nonatomic, assign) CGFloat scale;

+(CGAffineTransform) idealTransformForScrap:(MMScrapView*)scrap;

@end
