//
//  SYSaveMessageView.m
//  TouchChart
//
//  Created by Fernando Garcia Torcelly on 19/09/12.
//
//

#import "SYSaveMessageView.h"

@implementation SYSaveMessageView

- (void) drawRect:(CGRect)rect
{
    // General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Color Declarations
    UIColor* gradientColor = [UIColor colorWithRed: 0.16 green: 0.16 blue: 0.16 alpha: 1];
    UIColor* gradientColor2 = [UIColor colorWithRed: 0.11 green: 0.11 blue: 0.11 alpha: 1];
    UIColor* strokeColor = [UIColor colorWithRed: 0.36 green: 0.36 blue: 0.36 alpha: 0.5];
    UIColor* gradientColor3 = [UIColor colorWithRed: 0.11 green: 0.11 blue: 0.11 alpha: 1];
    UIColor* gradientColor4 = [UIColor colorWithRed: 0.16 green: 0.16 blue: 0.16 alpha: 0];
    UIColor* gradientColor5 = [UIColor colorWithRed: 0.25 green: 0.25 blue: 0.25 alpha: 1];
    UIColor* gradientColor6 = [UIColor colorWithRed: 0.35 green: 0.35 blue: 0.34 alpha: 1];
    UIColor* outterShadowButtonColor = [UIColor colorWithRed: 0.29 green: 0.29 blue: 0.29 alpha: 0.62];
    UIColor* highlightGradientColor = [UIColor colorWithRed: 0.26 green: 0.53 blue: 1 alpha: 1];
    UIColor* highlightGradientColor2 = [UIColor colorWithRed: 0.11 green: 0.34 blue: 0.63 alpha: 1];
    UIColor* textfieldGradientColor = [UIColor colorWithRed: 0.1 green: 0.1 blue: 0.1 alpha: 1];
    UIColor* textfieldGradientColor2 = [UIColor colorWithRed: 0.15 green: 0.15 blue: 0.15 alpha: 1];
    
    // Gradient Declarations
    NSArray* baseGradientColors = [NSArray arrayWithObjects:
                                   (id)gradientColor.CGColor,
                                   (id)gradientColor2.CGColor, nil];
    CGFloat baseGradientLocations[] = {0, 1};
    CGGradientRef baseGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)baseGradientColors, baseGradientLocations);
    NSArray* strokeGradientColors = [NSArray arrayWithObjects:
                                     (id)gradientColor4.CGColor,
                                     (id)[UIColor colorWithRed: 0.14 green: 0.14 blue: 0.14 alpha: 0.5].CGColor,
                                     (id)gradientColor3.CGColor, nil];
    CGFloat strokeGradientLocations[] = {0, 0.14, 1};
    CGGradientRef strokeGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)strokeGradientColors, strokeGradientLocations);
    NSArray* buttonGradientColors = [NSArray arrayWithObjects:
                                     (id)gradientColor6.CGColor,
                                     (id)gradientColor5.CGColor, nil];
    CGFloat buttonGradientLocations[] = {0, 1};
    CGGradientRef buttonGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)buttonGradientColors, buttonGradientLocations);
    NSArray* highlightGradientColors = [NSArray arrayWithObjects:
                                        (id)highlightGradientColor.CGColor,
                                        (id)highlightGradientColor2.CGColor, nil];
    CGFloat highlightGradientLocations[] = {0, 1};
    CGGradientRef highlightGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)highlightGradientColors, highlightGradientLocations);
    NSArray* textfieldGradientColors = [NSArray arrayWithObjects:
                                        (id)textfieldGradientColor.CGColor,
                                        (id)textfieldGradientColor2.CGColor, nil];
    CGFloat textfieldGradientLocations[] = {0, 1};
    CGGradientRef textfieldGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)textfieldGradientColors, textfieldGradientLocations);
    
    // Shadow Declarations
    UIColor* buttonLabelShadow = [UIColor blackColor];
    CGSize buttonLabelShadowOffset = CGSizeMake(0, 1);
    CGFloat buttonLabelShadowBlurRadius = 0;
    
    // Abstracted Graphic Attributes
    NSString* titleContent = @"Select Name";
    NSString* subtitleContent = @"Write the name for this case";
    NSString* buttonNormalLabelContent = @"Cancel";
    NSString* buttonHighlightLabelContent = @"Save";
    
    
    // Base Color Fill Drawing
    UIBezierPath* baseColorFillPath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(0, 0, 325, 180) cornerRadius: 8];
    CGContextSaveGState(context);
    [baseColorFillPath addClip];
    CGContextDrawLinearGradient(context, baseGradient, CGPointMake(162.5, -0), CGPointMake(162.5, 180), 0);
    CGContextRestoreGState(context);
    
    
    
    // Stroke Base Drawing
    UIBezierPath* strokeBasePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(1, 1, 323, 178) cornerRadius: 8];
    [strokeColor setStroke];
    strokeBasePath.lineWidth = 2;
    [strokeBasePath stroke];
    
    
    // Base Color Fill 2 Drawing
    UIBezierPath* baseColorFill2Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(0, -0.5, 325, 179.5) cornerRadius: 8];
    CGContextSaveGState(context);
    [baseColorFill2Path addClip];
    CGContextDrawLinearGradient(context, strokeGradient, CGPointMake(162.5, -0.5), CGPointMake(162.5, 179), 0);
    CGContextRestoreGState(context);
    
    
    
    // Title Drawing
    CGRect titleRect = CGRectMake(1, 24, 323, 32);
    [[UIColor whiteColor] setFill];
    [titleContent drawInRect:titleRect withFont: [UIFont fontWithName: @"HelveticaNeue-Bold" size: 16] lineBreakMode: NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
    
    
    // Subtitle Drawing
    CGRect subtitleRect = CGRectMake(1, 52, 323, 32);
    [[UIColor whiteColor] setFill];
    [subtitleContent drawInRect: subtitleRect withFont: [UIFont fontWithName: @"HelveticaNeue" size: [UIFont systemFontSize]] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
    
    
    // Button Normal Outter Stroke Drawing
    UIBezierPath* buttonNormalOutterStrokePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(50.5, 135.5, 104, 24) cornerRadius: 4];
    [outterShadowButtonColor setStroke];
    buttonNormalOutterStrokePath.lineWidth = 1;
    [buttonNormalOutterStrokePath stroke];
    
    
    // Button Normal Cancel Drawing
    UIBezierPath* buttonNormalCancelPath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(50.5, 134.5, 104, 24) cornerRadius: 4];
    CGContextSaveGState(context);
    [buttonNormalCancelPath addClip];
    CGContextDrawLinearGradient(context, buttonGradient, CGPointMake(102.5, 134.5), CGPointMake(102.5, 158.5), 0);
    CGContextRestoreGState(context);
    
    [[UIColor blackColor] setStroke];
    buttonNormalCancelPath.lineWidth = 1;
    [buttonNormalCancelPath stroke];
    
    
    // Button Normal Label Drawing
    CGRect buttonNormalLabelRect = CGRectMake(50, 137, 104, 23);
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, buttonLabelShadowOffset, buttonLabelShadowBlurRadius, buttonLabelShadow.CGColor);
    [[UIColor whiteColor] setFill];
    [buttonNormalLabelContent drawInRect: buttonNormalLabelRect withFont: [UIFont fontWithName: @"HelveticaNeue-Bold" size: 13] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
    CGContextRestoreGState(context);
    
    
    
    // Button Highlight Outter Stroke Drawing
    UIBezierPath* buttonHighlightOutterStrokePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(171.5, 135.5, 104, 24) cornerRadius: 4];
    [outterShadowButtonColor setStroke];
    buttonHighlightOutterStrokePath.lineWidth = 1;
    [buttonHighlightOutterStrokePath stroke];
    
    
    // Button Highlight Cancel Drawing
    UIBezierPath* buttonHighlightCancelPath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(171.5, 134.5, 104, 24) cornerRadius: 4];
    CGContextSaveGState(context);
    [buttonHighlightCancelPath addClip];
    CGContextDrawLinearGradient(context, highlightGradient, CGPointMake(223.5, 134.5), CGPointMake(223.5, 158.5), 0);
    CGContextRestoreGState(context);
    
    [[UIColor blackColor] setStroke];
    buttonHighlightCancelPath.lineWidth = 1;
    [buttonHighlightCancelPath stroke];
    
    
    // Button Highlight Label Drawing
    CGRect buttonHighlightLabelRect = CGRectMake(171, 137, 104, 23);
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, buttonLabelShadowOffset, buttonLabelShadowBlurRadius, buttonLabelShadow.CGColor);
    [[UIColor whiteColor] setFill];
    [buttonHighlightLabelContent drawInRect: buttonHighlightLabelRect withFont: [UIFont fontWithName: @"HelveticaNeue-Bold" size: 13] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
    CGContextRestoreGState(context);
    
    
    
    // Rounded Rectangle 2 Drawing
    UIBezierPath* roundedRectangle2Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(25, 88, 274, 24) cornerRadius: 4];
    [[UIColor blackColor] setStroke];
    roundedRectangle2Path.lineWidth = 2;
    [roundedRectangle2Path stroke];
    
    
    // Rounded Rectangle Drawing
    UIBezierPath* roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(25, 88, 274, 24) cornerRadius: 4];
    CGContextSaveGState(context);
    [roundedRectanglePath addClip];
    CGContextDrawLinearGradient(context, textfieldGradient, CGPointMake(162, 88), CGPointMake(162, 112), 0);
    CGContextRestoreGState(context);
    
    
    // Cleanup
    CGGradientRelease(baseGradient);
    CGGradientRelease(strokeGradient);
    CGGradientRelease(buttonGradient);
    CGGradientRelease(highlightGradient);
    CGGradientRelease(textfieldGradient);
    CGColorSpaceRelease(colorSpace);
    
}// drawRect

@end
