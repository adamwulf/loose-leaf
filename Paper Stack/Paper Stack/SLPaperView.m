//
//  SLPaperView.m
//  Paper Stack
//
//  Created by Adam Wulf on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SLPaperView.h"
#import <QuartzCore/QuartzCore.h>
#import "SLPanGestureRecognizer.h"
#import "SLPinchGestureRecognizer.h"


@interface SLPaperView (Private)

-(void) setScale:(CGFloat)_scale atLocation:(CGPoint)locationInView;

@end

@implementation SLPaperView

@synthesize scale;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIImage* img = [UIImage imageNamed:@"space.jpeg"];
        UIImageView* imgView = [[[UIImageView alloc] initWithImage:img] autorelease];
        imgView.frame = self.bounds;
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        imgView.clipsToBounds = YES;
        [self addSubview:imgView];
        
        preGestureScale = 1;
        scale = 1;
        
        [self.layer setMasksToBounds:NO ];
        [self.layer setShadowColor:[[UIColor blackColor ] CGColor ] ];
        [self.layer setShadowOpacity:0.5 ];
        [self.layer setShadowRadius:2.0 ];
        [self.layer setShadowOffset:CGSizeMake( 0 , 0 ) ];
        [self.layer setShouldRasterize:YES ];

        UIPanGestureRecognizer* panGesture = [[[SLPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAndScale:)] autorelease];
        [panGesture setMinimumNumberOfTouches:2];
        [panGesture setMaximumNumberOfTouches:2];
        [self addGestureRecognizer:panGesture];
    }
    return self;
}

-(void) panAndScale:(SLPanGestureRecognizer*)panGesture{
    CGPoint lastLocation = [panGesture locationInView:self.superview];
    CGPoint lastLocationInViewForScale = [panGesture locationInView:self];
    if(panGesture.numberOfTouches == 1){
        lastNumberOfTouchesForPanGesture = 1;
        return;
    }else if(lastNumberOfTouchesForPanGesture == 1){
        lastNumberOfTouchesForPanGesture = 2;
        firstLocationOfPanGesture = [panGesture locationInView:self.superview];
        firstFrameOfViewForGesture = self.frame;
        preGestureScale = scale;
        normalizedLocationOfScale = CGPointMake(lastLocationInViewForScale.x / self.frame.size.width, 
                                                lastLocationInViewForScale.y / self.frame.size.height);
    }
    if(panGesture.state == UIGestureRecognizerStateBegan){
        // for pan
        lastNumberOfTouchesForPanGesture = 2;
        firstLocationOfPanGesture = [panGesture locationInView:self.superview];
        firstFrameOfViewForGesture = self.frame;
        
        // for scale
        preGestureScale = scale;
        normalizedLocationOfScale = CGPointMake(lastLocationInViewForScale.x / self.frame.size.width, 
                                                lastLocationInViewForScale.y / self.frame.size.height);
        return;
    }
    if(panGesture.state == UIGestureRecognizerStateCancelled ||
       panGesture.state == UIGestureRecognizerStateEnded ||
       panGesture.state == UIGestureRecognizerStateFailed){
        // exit when we're done
        return;
    }
    
    // pan
    panDiffLocation = CGPointMake(lastLocation.x - firstLocationOfPanGesture.x, lastLocation.y - firstLocationOfPanGesture.y);
    
    // scale
    if(preGestureScale * panGesture.scale > .7){
        scale = preGestureScale * panGesture.scale;
    }else{
        scale = 0.7;
    }
    CGRect superBounds = self.superview.bounds;
    CGPoint locationOfPinchBeforeScale = CGPointMake(preGestureScale * normalizedLocationOfScale.x * superBounds.size.width, preGestureScale * normalizedLocationOfScale.y * superBounds.size.height);
    CGPoint locationOfPinchAfterScale = CGPointMake(scale * normalizedLocationOfScale.x * superBounds.size.width, scale * normalizedLocationOfScale.y * superBounds.size.height);
    CGPoint adjustmentForScale = CGPointMake((locationOfPinchAfterScale.x - locationOfPinchBeforeScale.x),
                                             (locationOfPinchAfterScale.y - locationOfPinchBeforeScale.y));
    CGSize newSizeOfView = CGSizeMake(superBounds.size.width * scale, superBounds.size.height * scale);

    
    
    CGRect fr = self.frame;
    fr.origin = CGPointMake(firstFrameOfViewForGesture.origin.x + panDiffLocation.x - adjustmentForScale.x,
                            firstFrameOfViewForGesture.origin.y + panDiffLocation.y - adjustmentForScale.y);
    fr.size = newSizeOfView;
    self.frame = fr;
    
}


@end
