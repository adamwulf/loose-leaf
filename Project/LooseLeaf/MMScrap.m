//
//  MMScrap.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/23/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMScrap.h"
#import "UIColor+ColorWithHex.h"
#import <CoreGraphics/CoreGraphics.h>

@implementation MMScrap{
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
        contentView.backgroundColor = [UIColor randomColor];
        CAShapeLayer* maskLayer = [CAShapeLayer layer];
        [maskLayer setPath:path.CGPath];
        contentView.layer.mask = maskLayer;
        [self addSubview:contentView];
        
        self.layer.shadowPath = path.CGPath;
        self.layer.shadowRadius = 2;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOpacity = 1;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        
        self.clipsToBounds = YES;
    }
    return self;
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
