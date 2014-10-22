//
//  MMCloudAvatarButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 10/22/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCloudAvatarButton.h"
#import "MMCloudKitButton.h"
#import "Constants.h"

@implementation MMCloudAvatarButton

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat smallest = MIN(self.bounds.size.width, self.bounds.size.height);
    CGFloat drawingWidth = (smallest - 2*kWidthOfSidebarButtonBuffer);
    CGRect frame = CGRectMake(kWidthOfSidebarButtonBuffer, kWidthOfSidebarButtonBuffer, drawingWidth, drawingWidth);
    
    //// Color Declarations
    UIColor* darkerGreyBorder = [self borderColor];
    UIColor* halfGreyFill = [self backgroundColor];
    
    
    CGContextSaveGState(context);
    
    
    UIBezierPath* glyphPath = [MMCloudKitButton cloudPathForFrame:CGRectInset(frame, kWidthOfSidebarButtonBuffer/2, kWidthOfSidebarButtonBuffer/2)];
    
    //// Oval Drawing
    
    CGRect ovalFrame = CGRectMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 0.5, floor(CGRectGetWidth(frame) - 1.0), floor(CGRectGetHeight(frame) - 1.0));
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect:ovalFrame];
    if(glyphPath){
        [ovalPath appendPath:glyphPath];
    }
    [ovalPath closePath];
    [halfGreyFill setFill];
    [ovalPath fill];
    
    [darkerGreyBorder setStroke];
    ovalPath.lineWidth = 1;
    [ovalPath stroke];
    
    if(self.shouldDrawDarkBackground){
        UIBezierPath* stripe = [UIBezierPath bezierPathWithOvalInRect:ovalFrame];
        CGContextSetBlendMode(context, kCGBlendModeClear);
        [[UIColor whiteColor] setStroke];
        [stripe stroke];
        CGContextSetBlendMode(context, kCGBlendModeNormal);
        [[self fontColor] setStroke];
        [stripe stroke];
    }
    
    
    if(glyphPath){
        //
        // clear the arrow and box, then fill with
        // border color
        CGContextSetBlendMode(context, kCGBlendModeClear);
        [[UIColor whiteColor] setFill];
        [glyphPath fill];
        CGContextSetBlendMode(context, kCGBlendModeNormal);
        
        [[self fontColor] setFill];
        [glyphPath fill];
    }
    
    CGContextRestoreGState(context);
}


@end
