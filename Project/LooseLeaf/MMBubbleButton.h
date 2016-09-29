//
//  MMBubbleButton.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/29/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMUUIDView.h"

@protocol MMBubbleButton <NSObject>

@property (nonatomic) UIView<MMUUIDView>* view;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) CGFloat originalViewScale;

#pragma mark - Scrap

+ (CGFloat)idealScaleForView:(UIView<MMUUIDView>*)view;

+ (CGAffineTransform)idealTransformForView:(UIView<MMUUIDView>*)view;

@end
