//
//  MMRotatingBackgroundView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 5/4/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMRotatingBackgroundView.h"
#import "UIImage+FXBlur.h"
#import "NSFileManager+DirectoryOptimizations.h"

static const NSInteger numberOfBackgrounds = 56;
static const CGFloat durationBetweenBackgroundTransitions = 60;
static const CGFloat durationOfTransition = 10;

@implementation MMRotatingBackgroundView{
    UIImageView* visibleBackgroundView;
    UIImageView* fadingBackgroundView;
    
    NSTimer* transitionTimer;
    NSInteger lastImage;
}

-(UIImage*)imageForNumber:(NSInteger)num{
    NSString* imageToLoad = [NSString stringWithFormat:@"bg%02ld.jpg", (long)num];
    return [UIImage imageNamed:imageToLoad];
}

-(instancetype) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){

        CGFloat parallaxDistance = 100;

        lastImage = (rand() % numberOfBackgrounds);
        
        CGRect bufferedFrame = CGRectInset(self.bounds, -parallaxDistance, -parallaxDistance);
        
        visibleBackgroundView = [[UIImageView alloc] initWithFrame:bufferedFrame];
        visibleBackgroundView.image = [self imageForNumber:lastImage];
        visibleBackgroundView.contentMode = UIViewContentModeScaleAspectFill;
        visibleBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:visibleBackgroundView];
        
        fadingBackgroundView = [[UIImageView alloc] initWithFrame:bufferedFrame];
        fadingBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        fadingBackgroundView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:fadingBackgroundView];
        
        visibleBackgroundView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        fadingBackgroundView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        
        
        // Set vertical effect
        UIInterpolatingMotionEffect *verticalMotionEffect =
        [[UIInterpolatingMotionEffect alloc]
         initWithKeyPath:@"center.y"
         type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
        verticalMotionEffect.minimumRelativeValue = @(-parallaxDistance);
        verticalMotionEffect.maximumRelativeValue = @(parallaxDistance);
        
        // Set horizontal effect
        UIInterpolatingMotionEffect *horizontalMotionEffect =
        [[UIInterpolatingMotionEffect alloc]
         initWithKeyPath:@"center.x"
         type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
        horizontalMotionEffect.minimumRelativeValue = @(-parallaxDistance);
        horizontalMotionEffect.maximumRelativeValue = @(parallaxDistance);
        
        // Create group to combine both
        UIMotionEffectGroup *group = [UIMotionEffectGroup new];
        group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
        
        // Add both effects to your view
        [self addMotionEffect:group];
        
        
        transitionTimer = [NSTimer scheduledTimerWithTimeInterval:durationBetweenBackgroundTransitions target:self selector:@selector(transitionBackground:) userInfo:nil repeats:NO];
    }
    return self;
}

-(void) transitionBackground:(id)sender{
    transitionTimer = nil;
    fadingBackgroundView.alpha = 0.0;
    
    NSInteger nextImage;
    do{
        nextImage = (rand() % numberOfBackgrounds);
    }while (nextImage == lastImage);
    
    fadingBackgroundView.image = [self imageForNumber:nextImage];
    
    [UIView animateWithDuration:durationOfTransition delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        fadingBackgroundView.alpha = 1;
    } completion:^(BOOL finished) {
        lastImage = nextImage;
        
        UIImageView* v = fadingBackgroundView;
        fadingBackgroundView = visibleBackgroundView;
        visibleBackgroundView = v;
        // reset order
        fadingBackgroundView.alpha = 0;
        fadingBackgroundView.image = nil;
        [self addSubview:fadingBackgroundView];

        transitionTimer = [NSTimer scheduledTimerWithTimeInterval:durationBetweenBackgroundTransitions target:self selector:@selector(transitionBackground:) userInfo:nil repeats:NO];
    }];
}

@end
