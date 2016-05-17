//
//  MMGenericBackgroundView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 5/16/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MMScrapBackgroundView, MMScrapViewState;

@interface MMGenericBackgroundView : UIView

-(id) initWithImage:(UIImage*)img;

@property (nonatomic, assign) CGFloat backgroundRotation;
@property (nonatomic, assign) CGFloat backgroundScale;
@property (nonatomic, assign) CGPoint backgroundOffset;
@property (nonatomic, retain) UIImage* backingImage;

-(UIView*) contextView;

-(CGFloat) contextRotation;

-(CGPoint) currentCenterOfBackground;

-(MMScrapBackgroundView*) stampBackgroundFor:(MMScrapViewState*)targetScrapState;

@end
