//
//  MMHandwritingTemplateView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 4/5/17.
//  Copyright © 2017 Milestone Made, LLC. All rights reserved.
//

#import "MMHandwritingTemplateView.h"
#import "MMScrapViewState.h"
#import "MMScrapBackgroundView.h"
#import "NSFileManager+DirectoryOptimizations.h"
#import "UIView+MPHelpers.h"
#import "Constants.h"

@implementation MMHandwritingTemplateView

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
    blueLines.path = [[self pathForBlueLines] CGPath];
    blueLines.backgroundColor = [UIColor clearColor].CGColor;
    blueLines.strokeColor = [self lightBlue].CGColor;
    blueLines.fillColor = [UIColor clearColor].CGColor;
    
    [[self layer] addSublayer:blueLines];
    
    
    CAShapeLayer* redLines = [CAShapeLayer layer];
    redLines.path = [[self pathForRedLines] CGPath];
    redLines.backgroundColor = [UIColor clearColor].CGColor;
    redLines.strokeColor = [self lightRed].CGColor;
    redLines.fillColor = [UIColor clearColor].CGColor;
    redLines.lineDashPattern = @[@(8 * [self scale].x), @(6 * [self scale].x)];
    redLines.lineDashPhase = 0;
    
    [[self layer] addSublayer:redLines];
}

-(UIColor*)lightBlue{
    return [UIColor colorWithRed:16/255.0 green:178/255.0 blue:242/255.0 alpha:1.0];
}

-(UIColor*)lightRed{
    return [UIColor colorWithRed:238/255.0 green:91/255.0 blue:162/255.0 alpha:1.0];
}

-(UIBezierPath*) pathForBlueLines{
    CGFloat verticalMargin = [UIDevice ppi] * 1.2 / [[UIScreen mainScreen] scale];
    CGFloat verticalSpacing = [UIDevice ppi] * .75 / [[UIScreen mainScreen] scale];
    CGFloat horizontalMargin = [UIDevice ppi] * .75 / [[UIScreen mainScreen] scale];
    CGFloat singleLineSpacing = [UIDevice ppi] * 1 / [[UIScreen mainScreen] scale];
    
    UIBezierPath* path = [UIBezierPath bezierPath];
    CGFloat y = verticalMargin;
    while (y < originalSize.height - verticalMargin) {
        [path moveToPoint:CGPointMake(horizontalMargin, y)];
        [path addLineToPoint:CGPointMake(originalSize.width - horizontalMargin, y)];

        y += singleLineSpacing;

        [path moveToPoint:CGPointMake(horizontalMargin, y)];
        [path addLineToPoint:CGPointMake(originalSize.width - horizontalMargin, y)];
        y += verticalSpacing;
    }
    
    [path applyTransform:CGAffineTransformMakeScale([self scale].x, [self scale].y)];
    
    return path;
}

-(UIBezierPath*) pathForRedLines{
    CGFloat verticalMargin = [UIDevice ppi] * 1.2 / [[UIScreen mainScreen] scale];
    CGFloat verticalSpacing = [UIDevice ppi] * .75 / [[UIScreen mainScreen] scale];
    CGFloat horizontalMargin = [UIDevice ppi] * .75 / [[UIScreen mainScreen] scale];
    CGFloat singleLineSpacing = [UIDevice ppi] * 1 / [[UIScreen mainScreen] scale];
    
    UIBezierPath* path = [UIBezierPath bezierPath];
    CGFloat outsideBorderPattern[] = {8 * [self scale].x, 6 * [self scale].x};
    [path setLineDash:outsideBorderPattern count:2 phase:0];
    CGFloat y = verticalMargin;
    while (y < originalSize.height) {
        y += singleLineSpacing / 2;
        
        [path moveToPoint:CGPointMake(horizontalMargin, y)];
        [path addLineToPoint:CGPointMake(originalSize.width - horizontalMargin, y)];

        y += singleLineSpacing / 2;
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
        
        [[self lightBlue] setStroke];
        [[self pathForBlueLines] stroke];
        
        [[self lightRed] setStroke];
        [[self pathForRedLines] stroke];
    });
}

@end
