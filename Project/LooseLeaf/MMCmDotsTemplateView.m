//
//  MMCmDotsTemplateView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 4/4/17.
//  Copyright © 2017 Milestone Made, LLC. All rights reserved.
//

#import "MMCmDotsTemplateView.h"
#import "MMScrapViewState.h"
#import "MMScrapBackgroundView.h"
#import "NSFileManager+DirectoryOptimizations.h"
#import "UIView+MPHelpers.h"
#import "Constants.h"

@implementation MMCmDotsTemplateView

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
    CAShapeLayer* dotsLayer = [CAShapeLayer layer];
    dotsLayer.path = [[self pathForDots] CGPath];
    dotsLayer.backgroundColor = [UIColor clearColor].CGColor;
    dotsLayer.strokeColor = [UIColor clearColor].CGColor;
    dotsLayer.fillColor = [UIColor lightGrayColor].CGColor;
    
    [[self layer] addSublayer:dotsLayer];
}

-(UIBezierPath*) pathForDots{
    
    CGFloat spacing = [UIDevice ppc] * 1 / [[UIScreen mainScreen] scale];
    CGFloat dotRadius = 1.5;
    
    if([self scale].x < .5){
        dotRadius /= MAX([self scale].x, .3);
    }
    
    UIBezierPath* path = [UIBezierPath bezierPath];
    
    BOOL firstY = YES;
    CGFloat y = 0;
    while (y < originalSize.height / 2) {
        BOOL firstX = YES;
        CGFloat x = 0;
        while (x < originalSize.width / 2) {
            [path appendPath:[UIBezierPath bezierPathWithOvalInRect:CGRectMake(originalSize.width / 2 + x - dotRadius, originalSize.height / 2 + y - dotRadius, dotRadius * 2, dotRadius * 2)]];
            
            if(!firstX){
                [path appendPath:[UIBezierPath bezierPathWithOvalInRect:CGRectMake(originalSize.width / 2 - x - dotRadius, originalSize.height / 2 + y - dotRadius, dotRadius * 2, dotRadius * 2)]];
            }

            if(!firstY){
                [path appendPath:[UIBezierPath bezierPathWithOvalInRect:CGRectMake(originalSize.width / 2 + x - dotRadius, originalSize.height / 2 - y - dotRadius, dotRadius * 2, dotRadius * 2)]];
                
                if(!firstX){
                    [path appendPath:[UIBezierPath bezierPathWithOvalInRect:CGRectMake(originalSize.width / 2 - x - dotRadius, originalSize.height / 2 - y - dotRadius, dotRadius * 2, dotRadius * 2)]];
                }
            }

            x += spacing;
            firstX = NO;
        }
        
        y += spacing;
        firstY = NO;
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
        
        [[UIColor lightGrayColor] setFill];
        [[self pathForDots] fill];
    });
}

@end
