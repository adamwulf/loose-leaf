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
#import "MMRotationManager.h"

@implementation MMScrapView{
    UIBezierPath* path;
    UIView* contentView;
}

- (id)initWithBezierPath:(UIBezierPath*)_path
{
    _path = [_path copy];
    CGRect originalBounds = _path.bounds;
    [_path applyTransform:CGAffineTransformMakeTranslation(-originalBounds.origin.x + 4, -originalBounds.origin.y + 4)];

    // twice the shadow
    if ((self = [super initWithFrame:CGRectInset(originalBounds, -4, -4)])) {
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
