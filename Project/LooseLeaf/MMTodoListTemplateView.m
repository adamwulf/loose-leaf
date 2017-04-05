//
//  MMTodoListTemplateView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 4/4/17.
//  Copyright © 2017 Milestone Made, LLC. All rights reserved.
//

#import "MMTodoListTemplateView.h"
#import "MMScrapViewState.h"
#import "MMScrapBackgroundView.h"
#import "NSFileManager+DirectoryOptimizations.h"
#import "UIView+MPHelpers.h"
#import "Constants.h"

@implementation MMTodoListTemplateView

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
    blueLines.path = [[self pathForCheckboxes] CGPath];
    blueLines.backgroundColor = [UIColor clearColor].CGColor;
    blueLines.strokeColor = [UIColor blackColor].CGColor;
    blueLines.fillColor = [UIColor clearColor].CGColor;
    
    [[self layer] addSublayer:blueLines];
}

-(UIBezierPath*) pathForCheckboxes{
    
    CGFloat verticalSpacing = [UIDevice ppi] * .70 / [[UIScreen mainScreen] scale];
    CGFloat verticalMargin = [UIDevice ppi] * 1.5 / [[UIScreen mainScreen] scale];
    CGFloat horizontalMargin = [UIDevice ppi] * 1.5 / [[UIScreen mainScreen] scale];
    CGFloat checkbox = [UIDevice ppc] * .5 / [[UIScreen mainScreen] scale];
    
    UIBezierPath* path = [UIBezierPath bezierPath];
    CGFloat y = verticalMargin;
    while (y < originalSize.height - verticalMargin) {
        [path appendPath:[UIBezierPath bezierPathWithRoundedRect:CGRectMake(horizontalMargin - checkbox/2, y - checkbox, checkbox, checkbox) cornerRadius:checkbox / 4]];
        
        [path moveToPoint:CGPointMake(horizontalMargin + checkbox * 1.5, y)];
        [path addLineToPoint:CGPointMake(originalSize.width - horizontalMargin, y)];
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
        [[self pathForCheckboxes] stroke];
    });
}

@end
