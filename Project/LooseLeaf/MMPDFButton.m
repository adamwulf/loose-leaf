//
//  MMPDFButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 5/23/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMPDFButton.h"
#import "Constants.h"
#import "UIFont+UIBezierCurve.h"

@implementation MMPDFButton{
    CGFloat pointSize;
    CGFloat xOffset;
    CGFloat yOffset;
    UIFont* font;
    NSString* textForButton;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        
        pointSize = 15;
        xOffset = 1;
        yOffset = -1;
        font = [UIFont boldSystemFontOfSize:pointSize];
        textForButton = @"PDF";
    }
    return self;
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* darkerGreyBorder = [self borderColor];
    UIColor* barelyWhite = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.25];
    UIColor* mostlyWhite = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.65];

    //// font size helpers
    CGFloat smallest = MIN(self.bounds.size.width, self.bounds.size.height);
    CGFloat drawingWidth = (smallest - 2*kWidthOfSidebarButtonBuffer);
    CGFloat scaledPointSize = drawingWidth * pointSize / (kWidthOfSidebarButton - 2*kWidthOfSidebarButtonBuffer);

    //// Gradient Declarations
    NSArray* backgroundGradientColors = [NSArray arrayWithObjects:
                                   (id)mostlyWhite.CGColor,
                                   (id)[UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.449].CGColor,
                                   (id)barelyWhite.CGColor, nil];
    CGFloat backgroundGradientLocations[] = {0, 0.51, 1};
    CGGradientRef backgroundGradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)backgroundGradientColors, backgroundGradientLocations);
    
    //// Oval
    UIBezierPath* ovalPath = [self ovalPath];
    
    CGContextSaveGState(context);
    [ovalPath addClip];
    CGRect ovalBounds = CGPathGetPathBoundingBox(ovalPath.CGPath);
    CGContextDrawLinearGradient(context, backgroundGradient,
                                CGPointMake(CGRectGetMidX(ovalBounds), CGRectGetMinY(ovalBounds)),
                                CGPointMake(CGRectGetMidX(ovalBounds), CGRectGetMaxY(ovalBounds)),
                                0);
    CGContextRestoreGState(context);
    
    

    // clip outside the circle
    UIBezierPath *circleClipPath = [UIBezierPath bezierPathWithRect:CGRectInfinite];
    [circleClipPath appendPath:ovalPath];
    circleClipPath.usesEvenOddFillRule = YES;
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [circleClipPath fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    
    // stroke circle
    [darkerGreyBorder setStroke];
    ovalPath.lineWidth = 1;
    [ovalPath stroke];
    
    
    
    // create path for text
    UIBezierPath* glyphPath = [[font fontWithSize:scaledPointSize] bezierPathForString:textForButton];
    CGRect glyphRect = [glyphPath bounds];
    [glyphPath applyTransform:CGAffineTransformConcat(CGAffineTransformMakeTranslation(-glyphRect.origin.x - .5 + xOffset, -glyphRect.size.height + yOffset),
                                                      CGAffineTransformMakeScale(1.f, -1.f))];
    [glyphPath applyTransform:CGAffineTransformMakeTranslation((drawingWidth - glyphRect.size.width) / 2 + kWidthOfSidebarButtonBuffer,
                                                               (drawingWidth - glyphRect.size.height) / 2 + kWidthOfSidebarButtonBuffer)];
    // clip and fill the text
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [glyphPath fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    
    [darkerGreyBorder setFill];
    [glyphPath fill];

    
    
    
    [self drawDropshadowIfSelected];
    
    [super drawRect:rect];
}

@end
