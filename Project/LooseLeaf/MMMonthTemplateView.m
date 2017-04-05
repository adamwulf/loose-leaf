//
//  MMMonthTemplateView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 4/5/17.
//  Copyright © 2017 Milestone Made, LLC. All rights reserved.
//

#import "MMMonthTemplateView.h"
#import "MMScrapViewState.h"
#import "MMScrapBackgroundView.h"
#import "NSFileManager+DirectoryOptimizations.h"
#import "UIView+MPHelpers.h"
#import "Constants.h"

@implementation MMMonthTemplateView

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
}

-(UIBezierPath*) path{
    
    CGFloat margin = [UIDevice ppi] * 1 / [[UIScreen mainScreen] scale];
    CGFloat boxHeight = originalSize.height - 2 * margin;
    CGFloat boxWidth = originalSize.width - 2 * margin;
    
    UIBezierPath* path = [UIBezierPath bezierPath];
    
    CGFloat y = margin;
    
    [path appendPath:[UIBezierPath bezierPathWithRect:CGRectMake(margin, y, boxWidth, boxHeight)]];

    for (NSInteger i = 1; i<7; i++) {
        [path moveToPoint:CGPointMake(margin, margin + boxHeight * i / 7)];
        [path addLineToPoint:CGPointMake(margin + boxWidth, margin + boxHeight * i / 7)];
    }

    for (NSInteger i = 1; i<6; i++) {
        [path moveToPoint:CGPointMake(margin + boxWidth * i / 6, margin)];
        [path addLineToPoint:CGPointMake(margin + boxWidth * i / 6, margin + boxHeight)];
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
    });
}

@end
