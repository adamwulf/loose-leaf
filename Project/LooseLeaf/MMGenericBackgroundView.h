//
//  MMGenericBackgroundView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 5/16/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMGenericBackgroundViewDelegate.h"

@class MMScrapBackgroundView, MMScrapViewState;

@interface MMGenericBackgroundView : UIView

-(id) initWithImage:(UIImage*)img andDelegate:(NSObject<MMGenericBackgroundViewDelegate>*)delegate;

@property (nonatomic, weak) NSObject<MMGenericBackgroundViewDelegate>* delegate;
@property (nonatomic, assign) CGFloat backgroundRotation;
@property (nonatomic, assign) CGFloat backgroundScale;
@property (nonatomic, assign) CGPoint backgroundOffset;
@property (nonatomic, retain) UIImage* backingImage;

-(void) aspectFillBackgroundImageIntoView;

-(MMScrapBackgroundView*) stampBackgroundFor:(MMScrapViewState*)targetScrapState;

@end
