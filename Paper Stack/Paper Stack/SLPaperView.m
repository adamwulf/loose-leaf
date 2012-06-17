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

        UIPanGestureRecognizer* panGesture = [[[SLPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)] autorelease];
        [panGesture setMinimumNumberOfTouches:2];
        [panGesture setMaximumNumberOfTouches:2];
//        [self addGestureRecognizer:panGesture];
        
        UIPinchGestureRecognizer* pinchGesture = [[[SLPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)] autorelease];
        [self addGestureRecognizer:pinchGesture];
    }
    return self;
}

-(void) pan:(UIPanGestureRecognizer*)panGesture{
    CGPoint lastLocation = [panGesture locationInView:self.superview];
    if(panGesture.numberOfTouches == 1){
        lastNumberOfTouchesForPanGesture = 1;
        return;
    }else if(lastNumberOfTouchesForPanGesture == 1){
        lastNumberOfTouchesForPanGesture = 2;
        firstLocationOfPanGesture = [panGesture locationInView:self.superview];
        firstFrameOfViewForGesture = self.frame;
    }
    if(panGesture.state == UIGestureRecognizerStateBegan){
        lastNumberOfTouchesForPanGesture = 2;
        firstLocationOfPanGesture = [panGesture locationInView:self.superview];
        firstFrameOfViewForGesture = self.frame;
        return;
    }
    if(panGesture.state == UIGestureRecognizerStateCancelled ||
       panGesture.state == UIGestureRecognizerStateEnded ||
       panGesture.state == UIGestureRecognizerStateFailed){
        // exit when we're done
        return;
    }
    
    
    panDiffLocation = CGPointMake(lastLocation.x - firstLocationOfPanGesture.x, lastLocation.y - firstLocationOfPanGesture.y);
    
    CGRect fr = self.frame;
    fr.origin = CGPointMake(firstFrameOfViewForGesture.origin.x + panDiffLocation.x, firstFrameOfViewForGesture.origin.y + panDiffLocation.y);
    self.frame = fr;
}

-(void) pinch:(UIPinchGestureRecognizer*)pinchGesture{
    //    NSLog(@"pinch %f", pinchGesture.scale);
    CGPoint lastLocationInViewForScale = [pinchGesture locationInView:self];

    if(pinchGesture.numberOfTouches == 1){
        lastNumberOfTouchesForPinchGesture = 1;
        return;
    }else if(lastNumberOfTouchesForPinchGesture == 1){
        lastNumberOfTouchesForPinchGesture = 2;
        normalizedLocationOfScale = CGPointMake(lastLocationInViewForScale.x / self.frame.size.width, 
                                                lastLocationInViewForScale.y / self.frame.size.height);
    }
    if(pinchGesture.state == UIGestureRecognizerStateBegan){
        preGestureScale = scale;
    }
    if(pinchGesture.state == UIGestureRecognizerStateCancelled ||
       pinchGesture.state == UIGestureRecognizerStateEnded ||
       pinchGesture.state == UIGestureRecognizerStateFailed){
        // exit when we're done
        return;
    }
    
    
    if(preGestureScale * pinchGesture.scale < .7){
        //        debug_NSLog(@"pinch all out to desk %f", pinchGesture.scale);
        [self setScale:0.7 atLocation:lastLocationInViewForScale];
    }else{
        if(pinchGesture.state == UIGestureRecognizerStateBegan){
            normalizedLocationOfScale = CGPointMake(lastLocationInViewForScale.x / self.frame.size.width, 
                                                    lastLocationInViewForScale.y / self.frame.size.height);
        }
        [self setScale:preGestureScale * pinchGesture.scale atLocation:lastLocationInViewForScale];
    }
    
}

-(void) setScale:(CGFloat)_scale{
    [self setScale:_scale atLocation:self.center];
}

-(void) setScale:(CGFloat)_scale atLocation:(CGPoint)locationInView{
    scale = _scale;
    CGRect superBounds = self.superview.bounds;
    CGRect oldBounds = self.frame;
    CGRect newBounds = oldBounds;
    
    //
    // calculate the size of the scale
    CGSize newSizeOfView = CGSizeMake(superBounds.size.width * scale, superBounds.size.height * scale);
    newBounds.size = newSizeOfView;
    
    CGPoint newLocationInView = CGPointMake(normalizedLocationOfScale.x * newSizeOfView.width, normalizedLocationOfScale.y * newSizeOfView.height);
    
    CGPoint adjustmentForScale = CGPointMake((locationInView.x - newLocationInView.x), (locationInView.y - newLocationInView.y));
    CGPoint newOriginForBounds = CGPointMake(oldBounds.origin.x + adjustmentForScale.x, oldBounds.origin.y + adjustmentForScale.y);
    newBounds.origin = newOriginForBounds;
    
    self.frame = newBounds;

    /*
    CGRect fr = self.frame;
    fr.origin = CGPointMake(firstFrameOfViewForGesture.origin.x + panDiffLocation.x + sumAdjustmentForScale.x,
                            firstFrameOfViewForGesture.origin.y + panDiffLocation.y + sumAdjustmentForScale.y);
    self.frame = fr;
*/
}

@end
