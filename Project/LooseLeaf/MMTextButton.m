//
//  MMPlusButton.m
//  Loose Leaf
//
//  Created by Adam Wulf on 6/21/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "MMTextButton.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"
#import "UIFont+UIBezierCurve.h"


@implementation MMTextButton {
    BOOL inverted;
}

@synthesize inverted;

- (id)initWithFrame:(CGRect)_frame andFont:(UIFont*)_font andLetter:(NSString*)_letter andXOffset:(CGFloat)_xOffset andYOffset:(CGFloat)_yOffset {
    self = [super initWithFrame:_frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        letter = _letter;
        pointSize = [_font pointSize] * kWidthOfSidebarButton / 50.0;
        xOffset = _xOffset;
        yOffset = _yOffset;
        font = _font;
    }
    return self;
}

- (UIColor*)backgroundColor {
    if (inverted) {
        return [super backgroundColor];
    }
    return [[UIColor whiteColor] colorWithAlphaComponent:.7];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat smallest = MIN(self.bounds.size.width, self.bounds.size.height);
    CGFloat drawingWidth = (smallest - 2 * kWidthOfSidebarButtonBuffer);
    CGRect frame = CGRectMake(kWidthOfSidebarButtonBuffer, kWidthOfSidebarButtonBuffer, drawingWidth, drawingWidth);
    CGFloat scaledPointSize = drawingWidth * pointSize / (kWidthOfSidebarButton - 2 * kWidthOfSidebarButtonBuffer);

    //// Color Declarations
    UIColor* darkerGreyBorder = [self borderColor];
    UIColor* halfGreyFill = [self backgroundColor];
    //    UIColor* barelyWhite = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.25];


    CGContextSaveGState(context);


    UIBezierPath* glyphPath = [[font fontWithSize:scaledPointSize] bezierPathForString:letter];
    CGRect glyphRect = [glyphPath bounds];
    [glyphPath applyTransform:CGAffineTransformConcat(CGAffineTransformMakeTranslation(-glyphRect.origin.x - .5 + xOffset, -glyphRect.size.height + yOffset),
                                                      CGAffineTransformMakeScale(1.f, -1.f))];
    [glyphPath applyTransform:CGAffineTransformMakeTranslation((drawingWidth - glyphRect.size.width) / 2 + kWidthOfSidebarButtonBuffer,
                                                               (drawingWidth - glyphRect.size.height) / 2 + kWidthOfSidebarButtonBuffer)];


    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 0.5, floor(CGRectGetWidth(frame) - 1.0), floor(CGRectGetHeight(frame) - 1.0))];
    [ovalPath appendPath:glyphPath];
    [ovalPath closePath];
    [halfGreyFill setFill];
    [ovalPath fill];


    [self drawDropshadowIfSelected];

    ovalPath.lineWidth = 1;
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setStroke];
    [ovalPath stroke];
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    [darkerGreyBorder setStroke];
    [ovalPath stroke];


    //
    // clear the arrow and box, then fill with
    // border color
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [glyphPath fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);

    if (inverted) {
        //        [barelyWhite setFill];
        //        [glyphPath fill];
        //        CGContextSetBlendMode(context, kCGBlendModeClear);
        //        [[UIColor whiteColor] setStroke];
        //        [glyphPath stroke];
        //        CGContextSetBlendMode(context, kCGBlendModeNormal);
        //        [darkerGreyBorder setStroke];
        //        [glyphPath stroke];
        [darkerGreyBorder setFill];
        [glyphPath fill];
    } else {
        [darkerGreyBorder setFill];
        [glyphPath fill];
    }

    CGContextRestoreGState(context);

    [super drawRect:rect];
}


@end
