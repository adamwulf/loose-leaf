//
//  MMMusicTemplateView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 4/4/17.
//  Copyright © 2017 Milestone Made, LLC. All rights reserved.
//

#import "MMMusicTemplateView.h"
#import "MMScrapViewState.h"
#import "MMScrapBackgroundView.h"
#import "NSFileManager+DirectoryOptimizations.h"
#import "UIView+MPHelpers.h"
#import "Constants.h"

@implementation MMMusicTemplateView

-(instancetype) initWithFrame:(CGRect)frame andOriginalSize:(CGSize)_originalSize andProperties:(NSDictionary*)properties{
    if(self = [super initWithFrame:frame andOriginalSize:_originalSize andProperties:properties]){
        [self finishInit];
    }
    
    return self;
}

-(instancetype) initWithFrame:(CGRect)frame andProperties:(NSDictionary*)properties{
    if(self = [super initWithFrame:frame andProperties:properties]){
        [self finishInit];
    }
    
    return self;
}

-(void) finishInit{
    CAShapeLayer* blueLines = [CAShapeLayer layer];
    blueLines.path = [[self path] CGPath];
    blueLines.backgroundColor = [UIColor clearColor].CGColor;
    blueLines.strokeColor = [UIColor blackColor].CGColor;
    blueLines.fillColor = [UIColor clearColor].CGColor;
    
    [[self layer] addSublayer:blueLines];

    CAShapeLayer* lineCapsLayer = [CAShapeLayer layer];
    lineCapsLayer.path = [[self pathCaps] CGPath];
    lineCapsLayer.backgroundColor = [UIColor clearColor].CGColor;
    lineCapsLayer.strokeColor = [UIColor clearColor].CGColor;
    lineCapsLayer.fillColor = [UIColor blackColor].CGColor;
    
    [[self layer] addSublayer:lineCapsLayer];
}

-(UIBezierPath*) path{
    
    CGFloat verticalSpacing = [UIDevice ppc] * 1.25 / [[UIScreen mainScreen] scale];
    CGFloat verticalMargin = [UIDevice ppi] * 1.5 / [[UIScreen mainScreen] scale];
    CGFloat horizontalMargin = [UIDevice ppi] * 1 / [[UIScreen mainScreen] scale];
    CGFloat lineSpacing = [UIDevice ppc] * .25 / [[UIScreen mainScreen] scale];
    
    UIBezierPath* path = [UIBezierPath bezierPath];
    
    CGFloat y = verticalMargin;
    
    while (y < originalSize.height - verticalMargin) {
        for (NSInteger line=0; line<5; line++) {
            [path moveToPoint:CGPointMake(horizontalMargin, y)];
            [path addLineToPoint:CGPointMake(originalSize.width - horizontalMargin, y)];
            y += lineSpacing;
        }
        y += verticalSpacing;
    }
    
    [path applyTransform:CGAffineTransformMakeScale([self scale].x, [self scale].y)];
    
    return path;
}

-(UIBezierPath*) pathCaps{
    
    CGFloat verticalSpacing = [UIDevice ppc] * 1.25 / [[UIScreen mainScreen] scale];
    CGFloat verticalMargin = [UIDevice ppi] * 1.5 / [[UIScreen mainScreen] scale];
    CGFloat horizontalMargin = [UIDevice ppi] * 1 / [[UIScreen mainScreen] scale];
    CGFloat lineSpacing = [UIDevice ppc] * .25 / [[UIScreen mainScreen] scale];
    
    UIBezierPath* path = [UIBezierPath bezierPath];
    
    CGFloat y = verticalMargin;
    
    while (y < originalSize.height - verticalMargin) {
        
        [path appendPath:[UIBezierPath bezierPathWithRect:CGRectMake(horizontalMargin, y, 4, 4 * lineSpacing)]];

        [path appendPath:[UIBezierPath bezierPathWithRect:CGRectMake(originalSize.width - horizontalMargin - 2, y, 2, 4 * lineSpacing)]];

        y += 5 * lineSpacing;
        y += verticalSpacing;
    }
    
    [path applyTransform:CGAffineTransformMakeScale([self scale].x, [self scale].y)];
    
    return path;
}

-(void) drawInContext:(CGContextRef)context forSize:(CGSize)size{
    CGRect scaledScreen = CGSizeFill(originalSize, size);
    
    CGContextSaveThenRestoreForBlock(context, ^{
        // Scraps
        // adjust so that (0,0) is the origin of the content rect in the PDF page,
        // since the PDF may be much taller/wider than our screen
        CGContextScaleCTM(context, size.width / pageSize.width, size.height / pageSize.height);
        CGContextTranslateCTM(context, -scaledScreen.origin.x, -scaledScreen.origin.y);
        
        [[UIColor blackColor] setStroke];
        [[self path] stroke];

        [[UIColor blackColor] setFill];
        [[self pathCaps] stroke];
    });
}

@end
