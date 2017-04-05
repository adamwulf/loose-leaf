//
//  MMRuledTemplateView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/30/17.
//  Copyright © 2017 Milestone Made, LLC. All rights reserved.
//

#import "MMRuledTemplateView.h"
#import "MMScrapViewState.h"
#import "MMScrapBackgroundView.h"
#import "NSFileManager+DirectoryOptimizations.h"
#import "UIView+MPHelpers.h"
#import "Constants.h"

@implementation MMRuledTemplateView

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
    
    [[self layer] addSublayer:redLines];
}

-(UIColor*)lightBlue{
    return [UIColor colorWithRed:16/255.0 green:178/255.0 blue:242/255.0 alpha:1.0];
}

-(UIColor*)lightRed{
    return [UIColor colorWithRed:238/255.0 green:91/255.0 blue:162/255.0 alpha:1.0];
}

-(UIBezierPath*) pathForBlueLines{
    
    CGFloat verticalSpacing = [UIDevice ppc] * .71 / [[UIScreen mainScreen] scale];
    CGFloat verticalMargin = [UIDevice ppi] * 1.5 / [[UIScreen mainScreen] scale];
    
    UIBezierPath* path = [UIBezierPath bezierPath];
    CGFloat y = verticalMargin;
    while (y < originalSize.height) {
        [path moveToPoint:CGPointMake(0, y)];
        [path addLineToPoint:CGPointMake(originalSize.width, y)];
        y += verticalSpacing;
    }
    
    [path applyTransform:CGAffineTransformMakeScale([self scale].x, [self scale].y)];
    
    return path;
}

-(UIBezierPath*) pathForRedLines{
    CGFloat horizontalSpacing = [UIDevice ppc] * 3.2 / [[UIScreen mainScreen] scale];
    
    UIBezierPath* path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(horizontalSpacing, 0)];
    [path addLineToPoint:CGPointMake(horizontalSpacing, originalSize.height)];
    [path moveToPoint:CGPointMake(horizontalSpacing + 2, 0)];
    [path addLineToPoint:CGPointMake(horizontalSpacing + 2, originalSize.height)];

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
