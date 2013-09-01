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
    UIView* contentView;
    CGFloat scale;
    CGFloat rotation;
    BOOL selected;
    CGRect originalBounds;
}

@synthesize scale;
@synthesize rotation;
@synthesize selected;
@synthesize originalBounds;

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
        
        contentView = [[UIView alloc] initWithFrame:self.bounds];
        contentView.clipsToBounds = YES;
        contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        contentView.backgroundColor = [UIColor whiteColor];
        CAShapeLayer* maskLayer = [CAShapeLayer layer];
        [maskLayer setPath:path.CGPath];
        contentView.layer.mask = maskLayer;
        [self addSubview:contentView];
        
        self.layer.shadowPath = path.CGPath;
        self.layer.shadowRadius = 1.5;
        self.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:.5].CGColor;
        self.layer.shadowOpacity = .65;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        
        self.clipsToBounds = YES;
        [self didUpdateAccelerometerWithRawReading:[[MMRotationManager sharedInstace] currentRawRotationReading]];
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
    contentView.backgroundColor = backgroundColor;
}

-(void) didUpdateAccelerometerWithRawReading:(CGFloat)currentRawReading{
//    NSLog(@"raw: %f  =>  %f,%f", currentRawReading, cosf(currentRawReading)*4, sinf(currentRawReading)*4);
    self.layer.shadowOffset = CGSizeMake(cosf(currentRawReading)*1, sinf(currentRawReading)*1);
}


-(BOOL) containsTouch:(UITouch*)touch{
    CGPoint locationOfTouch = [touch locationInView:self];
    return [path containsPoint:locationOfTouch];
}

-(NSSet*) matchingTouchesFrom:(NSSet*) touches{
    NSMutableSet* outArray = [NSMutableSet set];
    for(UITouch* touch in touches){
        if([self containsTouch:touch]){
            [outArray addObject:touch];
        }
    }
    if([outArray count] >= 2){
        return outArray;
    }
    return nil;
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

    self.transform = CGAffineTransformConcat(CGAffineTransformMakeRotation(rotation),CGAffineTransformMakeScale(scale, scale));
}

-(void) setScale:(CGFloat)_scale{
    [self setScale:_scale andRotation:self.rotation];
}

-(void) setRotation:(CGFloat)_rotation{
    [self setScale:self.scale andRotation:_rotation];
}



#pragma mark - Debug

// just a debug method to test difference and intersection
// operations on a path
-(UIBezierPath*) intersect:(UIBezierPath*)newPath{
    newPath = [newPath copy];
    [newPath applyTransform:CGAffineTransformMakeTranslation(-self.frame.origin.x, -self.frame.origin.y)];
    
    newPath = [path pathFromPath:newPath usingBooleanOperation:GPC_DIFF];
    
    self.layer.shadowPath = newPath.CGPath;

    CAShapeLayer* maskLayer = [CAShapeLayer layer];
    [maskLayer setPath:newPath.CGPath];
    contentView.layer.mask = maskLayer;

    
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
