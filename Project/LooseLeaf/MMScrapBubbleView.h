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
}

@property (nonatomic) MMScrapView* scrap;

+(CGAffineTransform) idealTransformForScrap:(MMScrapView*)scrap;

@end
