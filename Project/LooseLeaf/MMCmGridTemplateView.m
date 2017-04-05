//
//  MMCmGridTemplateView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 4/4/17.
//  Copyright © 2017 Milestone Made, LLC. All rights reserved.
//

#import "MMCmGridTemplateView.h"
#import "MMScrapViewState.h"
#import "MMScrapBackgroundView.h"
#import "NSFileManager+DirectoryOptimizations.h"
#import "UIView+MPHelpers.h"
#import "Constants.h"

@implementation MMCmGridTemplateView

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
    blueLines.path = [[self pathForVerticalLines] CGPath];
    blueLines.backgroundColor = [UIColor clearColor].CGColor;
    blueLines.strokeColor = [UIColor lightGrayColor].CGColor;
    blueLines.fillColor = [UIColor clearColor].CGColor;
    
    [[self layer] addSublayer:blueLines];
    
    
    CAShapeLayer* redLines = [CAShapeLayer layer];
    redLines.path = [[self pathForHorizontalLines] CGPath];
    redLines.backgroundColor = [UIColor clearColor].CGColor;
    redLines.strokeColor = [UIColor lightGrayColor].CGColor;
    redLines.fillColor = [UIColor clearColor].CGColor;
    
    [[self layer] addSublayer:redLines];
}

-(UIBezierPath*) pathForHorizontalLines{
    
    CGFloat verticalSpacing = [UIDevice ppc] * 1 / [[UIScreen mainScreen] scale];
    
    UIBezierPath* path = [UIBezierPath bezierPath];

    BOOL first = YES;
    CGFloat y = 0;
    while (y < originalSize.height) {
        [path moveToPoint:CGPointMake(0, originalSize.height / 2 - y)];
        [path addLineToPoint:CGPointMake(originalSize.width, originalSize.height / 2 - y)];

        if(!first){
            [path moveToPoint:CGPointMake(0, originalSize.height / 2 + y)];
            [path addLineToPoint:CGPointMake(originalSize.width, originalSize.height / 2 + y)];
        }
        
        y += verticalSpacing;
        first = NO;
    }
    
    [path applyTransform:CGAffineTransformMakeScale([self scale].x, [self scale].y)];
    
    return path;
}

-(UIBezierPath*) pathForVerticalLines{
    CGFloat horizontalSpacing = [UIDevice ppc] * 1 / [[UIScreen mainScreen] scale];
    
    UIBezierPath* path = [UIBezierPath bezierPath];
    
    BOOL first = YES;
    CGFloat y = 0;
    while (y < originalSize.height) {
        [path moveToPoint:CGPointMake(originalSize.width / 2 - y, 0)];
        [path addLineToPoint:CGPointMake(originalSize.width / 2 - y, originalSize.height)];
        
        if(!first){
            [path moveToPoint:CGPointMake(originalSize.width / 2 + y, 0)];
            [path addLineToPoint:CGPointMake(originalSize.width / 2 + y, originalSize.height)];
        }
        
        y += horizontalSpacing;
        first = NO;
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
        
        [[UIColor lightGrayColor] setStroke];
        [[self pathForVerticalLines] stroke];
        [[self pathForHorizontalLines] stroke];
    });
}

@end
