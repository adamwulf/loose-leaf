//
//  MMScrap.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/23/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMScrapView.h"
#import "UIColor+ColorWithHex.h"
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import "MMRotationManager.h"
#import "DrawKit-iOS.h"
#import "UIColor+Shadow.h"

@implementation MMScrapView{
    UIBezierPath* path;
    UIBezierPath* clippingPath;
    BOOL needsClippingPathUpdate;
    CAShapeLayer* contentLayer;
    CGFloat scale;
    CGFloat rotation;
    BOOL selected;
    CGRect originalBounds;
    JotView* drawableView;
}

@synthesize scale;
@synthesize rotation;
@synthesize selected;
@synthesize originalBounds;
@synthesize clippingPath;

- (id)initWithBezierPath:(UIBezierPath*)_path
{
    _path = [_path copy];
    originalBounds = _path.bounds;
    [_path applyTransform:CGAffineTransformMakeTranslation(-originalBounds.origin.x + 4, -originalBounds.origin.y + 4)];

    // twice the shadow
    if ((self = [super initWithFrame:CGRectInset(originalBounds, -4, -4)])) {
        scale = 1;
        // Initialization code
        path = _path;
        
        drawableView = [[JotView alloc] initWithFrame:self.bounds];
        drawableView.layer.borderColor = [UIColor redColor].CGColor;
        drawableView.layer.borderWidth = 1;
        
        contentLayer = [CAShapeLayer layer];
        [contentLayer setPath:path.CGPath];
        contentLayer.fillColor = [UIColor whiteColor].CGColor;
        contentLayer.masksToBounds = YES;
        contentLayer.frame = self.layer.bounds;
        [self.layer addSublayer:contentLayer];
        
        
//        CALayer* fakeContent = [CALayer layer];
//        fakeContent.frame = CGRectMake(0, 0, 500, 100);
//        fakeContent.backgroundColor = [UIColor redColor].CGColor;
//        [contentLayer addSublayer:fakeContent];
        
        
        self.layer.shadowPath = path.CGPath;
        self.layer.shadowRadius = 1.5;
        self.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:.5].CGColor;
        self.layer.shadowOpacity = .65;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        
        self.opaque = NO;
        self.clipsToBounds = YES;
        [self didUpdateAccelerometerWithRawReading:[[MMRotationManager sharedInstace] currentRawRotationReading]];
        needsClippingPathUpdate = YES;
        
        [self addSubview:drawableView];
    }
    return self;
}

-(CGPoint) firstPoint{
    return [path elementAtIndex:0].points[0];
}

-(UIBezierPath*) bezierPath{
    return path;
}

-(void) setSelected:(BOOL)_selected{
    selected = _selected;
    if(selected){
        self.layer.shadowColor = [[UIColor blueShadowColor] colorWithAlphaComponent:1].CGColor;
        self.layer.shadowRadius = 2.5;
    }else{
        self.layer.shadowRadius = 1.5;
        self.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:.5].CGColor;
    }
}

-(void) setBackgroundColor:(UIColor *)backgroundColor{
    contentLayer.fillColor = backgroundColor.CGColor;
}

-(void) didUpdateAccelerometerWithRawReading:(CGFloat)currentRawReading{
//    NSLog(@"raw: %f  =>  %f,%f", currentRawReading, cosf(currentRawReading)*4, sinf(currentRawReading)*4);
    self.layer.shadowOffset = CGSizeMake(cosf(currentRawReading)*1, sinf(currentRawReading)*1);
}


-(BOOL) containsTouch:(UITouch*)touch{
    CGPoint locationOfTouch = [touch locationInView:self];
    return [path containsPoint:locationOfTouch];
}

-(NSSet*) matchingPairTouchesFrom:(NSSet*) touches{
    NSSet* outArray = [self allMatchingTouchesFrom:touches];
    if([outArray count] >= 2){
        return outArray;
    }
    return nil;
}


-(NSSet*) allMatchingTouchesFrom:(NSSet*) touches{
    NSMutableSet* outArray = [NSMutableSet set];
    for(UITouch* touch in touches){
        if([self containsTouch:touch]){
            [outArray addObject:touch];
        }
    }
    return outArray;
}

-(void) setScale:(CGFloat)_scale andRotation:(CGFloat)_rotation{
//    if(_scale > 2) _scale = 2;
//    if(_scale * self.bounds.size.width < 100){
//        _scale = 100 / self.bounds.size.width;
//    }
//    if(_scale * self.bounds.size.height < 100){
//        _scale = 100 / self.bounds.size.height;
//    }
    scale = _scale;
    rotation = _rotation;
    needsClippingPathUpdate = YES;
    self.transform = CGAffineTransformConcat(CGAffineTransformMakeRotation(rotation),CGAffineTransformMakeScale(scale, scale));
}

-(void) setScale:(CGFloat)_scale{
    [self setScale:_scale andRotation:self.rotation];
}

-(void) setRotation:(CGFloat)_rotation{
    [self setScale:self.scale andRotation:_rotation];
}

-(void) setFrame:(CGRect)frame{
    [super setFrame:frame];
    needsClippingPathUpdate = YES;
}

-(void) setBounds:(CGRect)bounds{
    [super setBounds:bounds];
    needsClippingPathUpdate = YES;
}

-(void) setCenter:(CGPoint)center{
    [super setCenter:center];
    needsClippingPathUpdate = YES;
}

-(UIBezierPath*) clippingPath{
    if(needsClippingPathUpdate){
        [self commitEditsAndUpdateClippingPath];
        needsClippingPathUpdate = NO;
    }
    return clippingPath;
}

-(void) commitEditsAndUpdateClippingPath{
    // find the bounding box of the scrap, so we can determine
    // quickly if they even possibly intersect
    
    clippingPath = [self.bezierPath copy];
    
    // when we pick up a scrap with a two finger gesture, we also
    // change the position and anchor (which change the center), so
    // that it rotates underneath the gesture correctly.
    //
    // we need to re-caculate the true center of the scrap as if it
    // was not being held, so that we can position our path correctly
    // over it.
    CGPoint actualScrapCenter = CGPointMake( CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    CGPoint clippingPathCenter = clippingPath.center;
    
    // first, align the center of the scrap to the center of the path
    [clippingPath applyTransform:CGAffineTransformMakeTranslation(actualScrapCenter.x - clippingPathCenter.x, actualScrapCenter.y - clippingPathCenter.y)];
    // now we need to rotate the path around it's new center
    clippingPathCenter = clippingPath.center;
    CGAffineTransform rotateAndScale = CGAffineTransformConcat(CGAffineTransformMakeTranslation(-clippingPathCenter.x, -clippingPathCenter.y),
                                                               CGAffineTransformConcat(CGAffineTransformMakeRotation(self.rotation),CGAffineTransformMakeScale(self.scale, self.scale)));
    rotateAndScale = CGAffineTransformConcat(rotateAndScale, CGAffineTransformMakeTranslation(clippingPathCenter.x, clippingPathCenter.y));
    CGFloat height = self.superview.bounds.size.height;
    rotateAndScale = CGAffineTransformConcat(rotateAndScale, CGAffineTransformMake(1, 0, 0, -1, 0, height));
    [clippingPath applyTransform:rotateAndScale];
}



#pragma mark - JotView

-(void) addElement:(AbstractBezierPathElement *)element{
    [drawableView addElement:element];
}


#pragma mark - Debug

// just a debug method to test difference and intersection
// operations on a path
-(UIBezierPath*) intersect:(UIBezierPath*)newPath{
    newPath = [newPath copy];
    [newPath applyTransform:CGAffineTransformMakeTranslation(-self.frame.origin.x, -self.frame.origin.y)];
    
    newPath = [path pathFromPath:newPath usingBooleanOperation:GPC_DIFF];
    
    self.layer.shadowPath = newPath.CGPath;
    [contentLayer setPath:newPath.CGPath];
    
    path = newPath;
    
    return newPath;
}


#pragma mark - Ignore Touches

/**
 * these two methods make sure that the ruler view
 * can never intercept any touch input. instead it will
 * effectively pass through this view to the views behind it
 */
-(UIView*) hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    return nil;
}

-(BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    return NO;
}


@end
