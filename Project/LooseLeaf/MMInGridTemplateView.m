//
//  MMInGridTemplateView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 4/4/17.
//  Copyright © 2017 Milestone Made, LLC. All rights reserved.
//

#import "MMInGridTemplateView.h"
#import "MMScrapViewState.h"
#import "MMScrapBackgroundView.h"
#import "NSFileManager+DirectoryOptimizations.h"
#import "UIView+MPHelpers.h"
#import "Constants.h"

@implementation MMInGridTemplateView

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

-(UIColor*)superLightGray{
    return [UIColor colorWithWhite:.9 alpha:1];
}

-(void) finishInit{
    CAShapeLayer* inVerticalLines = [CAShapeLayer layer];
    inVerticalLines.path = [[self pathForThinLines] CGPath];
    inVerticalLines.backgroundColor = [UIColor clearColor].CGColor;
    inVerticalLines.strokeColor = [self superLightGray].CGColor;
    inVerticalLines.fillColor = [UIColor clearColor].CGColor;
    
    [[self layer] addSublayer:inVerticalLines];
    
    
    CAShapeLayer* inHorizontalLines = [CAShapeLayer layer];
    inHorizontalLines.path = [[self pathForWideLines] CGPath];
    inHorizontalLines.backgroundColor = [UIColor clearColor].CGColor;
    inHorizontalLines.strokeColor = [UIColor lightGrayColor].CGColor;
    inHorizontalLines.fillColor = [UIColor clearColor].CGColor;
    
    [[self layer] addSublayer:inHorizontalLines];
}

-(UIBezierPath*) pathForWideLines{
    CGFloat spacing = [UIDevice ppi] * 1 / [[UIScreen mainScreen] scale];
    
    UIBezierPath* path = [UIBezierPath bezierPath];
    
    BOOL first = YES;
    CGFloat y = 0;
    while (y < originalSize.height / 2) {
        [path moveToPoint:CGPointMake(0, originalSize.height / 2 - y)];
        [path addLineToPoint:CGPointMake(originalSize.width, originalSize.height / 2 - y)];
        
        if(!first){
            [path moveToPoint:CGPointMake(0, originalSize.height / 2 + y)];
            [path addLineToPoint:CGPointMake(originalSize.width, originalSize.height / 2 + y)];
        }
        
        y += spacing;
        first = NO;
    }
    
    first = YES;
    y = 0;
    while (y < originalSize.width / 2) {
        [path moveToPoint:CGPointMake(originalSize.width / 2 - y, 0)];
        [path addLineToPoint:CGPointMake(originalSize.width / 2 - y, originalSize.height)];
        
        if(!first){
            [path moveToPoint:CGPointMake(originalSize.width / 2 + y, 0)];
            [path addLineToPoint:CGPointMake(originalSize.width / 2 + y, originalSize.height)];
        }
        
        y += spacing;
        first = NO;
    }
    
    [path applyTransform:CGAffineTransformMakeScale([self scale].x, [self scale].y)];
    
    return path;
}

-(UIBezierPath*) pathForThinLines{
    CGFloat spacing = [UIDevice ppi] * .25 / [[UIScreen mainScreen] scale];
    
    UIBezierPath* path = [UIBezierPath bezierPath];
    
    BOOL first = YES;
    CGFloat y = 0;
    NSInteger counter = 0;
    while (y < originalSize.height / 2) {
        if(counter % 4 != 0){
            [path moveToPoint:CGPointMake(0, originalSize.height / 2 - y)];
            [path addLineToPoint:CGPointMake(originalSize.width, originalSize.height / 2 - y)];
            
            if(!first){
                [path moveToPoint:CGPointMake(0, originalSize.height / 2 + y)];
                [path addLineToPoint:CGPointMake(originalSize.width, originalSize.height / 2 + y)];
            }
        }
        
        y += spacing;
        first = NO;
        counter += 1;
    }
    
    first = YES;
    y = 0;
    counter = 0;
    while (y < originalSize.width / 2) {
        if(counter % 4 != 0){
            [path moveToPoint:CGPointMake(originalSize.width / 2 - y, 0)];
            [path addLineToPoint:CGPointMake(originalSize.width / 2 - y, originalSize.height)];
            
            if(!first){
                [path moveToPoint:CGPointMake(originalSize.width / 2 + y, 0)];
                [path addLineToPoint:CGPointMake(originalSize.width / 2 + y, originalSize.height)];
            }
        }
        
        y += spacing;
        first = NO;
        counter += 1;
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
        
        [[self superLightGray] setStroke];
        [[self pathForThinLines] stroke];
        
        [[UIColor lightGrayColor] setStroke];
        [[self pathForWideLines] stroke];
    });
}

@end
