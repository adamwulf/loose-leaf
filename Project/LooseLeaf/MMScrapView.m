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

@implementation MMScrapView{
    UIBezierPath* path;
    UIView* contentView;
    CGPoint unscaledOrigin;
}

@synthesize unscaledOrigin;

- (id)initWithBezierPath:(UIBezierPath*)_path
{
    _path = [_path copy];
    CGRect originalBounds = _path.bounds;
    [_path applyTransform:CGAffineTransformMakeTranslation(-originalBounds.origin.x + 4, -originalBounds.origin.y + 4)];

    // twice the shadow
    if ((self = [super initWithFrame:CGRectInset(originalBounds, -4, -4)])) {
        unscaledOrigin = self.frame.origin;
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

-(void) didUpdateAccelerometerWithRawReading:(CGFloat)currentRawReading{
//    NSLog(@"raw: %f  =>  %f,%f", currentRawReading, cosf(currentRawReading)*4, sinf(currentRawReading)*4);
    self.layer.shadowOffset = CGSizeMake(cosf(currentRawReading)*1, sinf(currentRawReading)*1);
}



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
