//
//  MMAvatarButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/27/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMAvatarButton.h"
#import <CoreText/CoreText.h>
#import "Constants.h"
#import "UIFont+UIBezierCurve.h"

@implementation MMAvatarButton{
    NSString* letter;
    CGFloat pointSize;
    CTFontSymbolicTraits traits;
    UIFont* font;
}

- (id)initWithFrame:(CGRect)_frame forLetter:(NSString*)_letter{
    self = [super initWithFrame:_frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        letter = _letter;
        font = [UIFont systemFontOfSize:16];
        pointSize = [font pointSize] * kWidthOfSidebarButton / 50.0;
    }
    return self;
}

-(UIColor*) backgroundColor{
    return [[UIColor whiteColor] colorWithAlphaComponent:.7];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat smallest = MIN(self.bounds.size.width, self.bounds.size.height);
    CGFloat drawingWidth = (smallest - 2*kWidthOfSidebarButtonBuffer);
    CGRect frame = CGRectMake(kWidthOfSidebarButtonBuffer, kWidthOfSidebarButtonBuffer, drawingWidth, drawingWidth);
    CGFloat scaledPointSize = drawingWidth * pointSize / (kWidthOfSidebarButton - 2*kWidthOfSidebarButtonBuffer);
    
    //// Color Declarations
    UIColor* darkerGreyBorder = [self borderColor];
    UIColor* halfGreyFill = [self backgroundColor];
    
    
    CGContextSaveGState(context);
    
    
    UIBezierPath* glyphPath = [[font fontWithSize:scaledPointSize] bezierPathForString:letter];
    CGRect glyphRect = [glyphPath bounds];
    [glyphPath applyTransform:CGAffineTransformConcat(CGAffineTransformMakeTranslation(-glyphRect.origin.x - .5, -glyphRect.size.height),
                                                      CGAffineTransformMakeScale(1.f, -1.f))];
    [glyphPath applyTransform:CGAffineTransformMakeTranslation((drawingWidth - glyphRect.size.width) / 2 + kWidthOfSidebarButtonBuffer,
                                                               (drawingWidth - glyphRect.size.height) / 2 + kWidthOfSidebarButtonBuffer)];
    
    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 0.5, floor(CGRectGetWidth(frame) - 1.0), floor(CGRectGetHeight(frame) - 1.0))];
    [ovalPath appendPath:glyphPath];
    [ovalPath closePath];
    [halfGreyFill setFill];
    [ovalPath fill];
    [darkerGreyBorder setStroke];
    ovalPath.lineWidth = 1;
    [ovalPath stroke];
    
    
    //
    // clear the arrow and box, then fill with
    // border color
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [glyphPath fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    
    [darkerGreyBorder setFill];
    [glyphPath fill];
    
    CGContextRestoreGState(context);
    
}

@end
