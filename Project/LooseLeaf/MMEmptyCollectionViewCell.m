//
//  MMEmptyCollectionViewCell.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/26/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMEmptyCollectionViewCell.h"
#import "MMImageIconView.h"
#import "UIView+Debug.h"



@implementation MMEmptyCollectionViewCell

-(id) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        CATextLayer* textLayer = [CATextLayer layer];
        textLayer.bounds = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.width);
        textLayer.string = @"0×";
        textLayer.font = CFBridgingRetain(@"Futura-Medium");
        textLayer.fontSize = 80;
        textLayer.foregroundColor = [UIColor whiteColor].CGColor;
        textLayer.backgroundColor = [UIColor clearColor].CGColor;
        textLayer.position = self.center;
        textLayer.alignmentMode = kCAAlignmentCenter;
        
        CAGradientLayer* textGradient = [CAGradientLayer layer];
        textGradient.bounds = textLayer.bounds;
        textGradient.position = CGPointMake(self.center.x, self.center.y+30);
        
        //// Color Declarations
        UIColor* fullWhite = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.682];
        UIColor* halfWhite = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.503];
        UIColor* barelyWhite = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.244];
        
        //// Gradient Declarations
        NSArray* gradient4Locations = @[@(0), @(0.23), @(0.52), @(1)];
        NSArray* colors = @[(id)fullWhite.CGColor, (id)[UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.592].CGColor, (id)halfWhite.CGColor, (id)barelyWhite.CGColor];
        
        textGradient.colors = colors;
        textGradient.locations = gradient4Locations;
        textGradient.mask = textLayer;

        
        [self.layer addSublayer:textGradient];

        CGFloat widthDiff = 20;
        MMImageIconView* icon = [[MMImageIconView alloc] initWithFrame:CGRectMake(widthDiff/2, 80,
                                                                                  self.bounds.size.width - widthDiff, self.bounds.size.width - widthDiff)];
        icon.backgroundColor = [UIColor clearColor];
        [self addSubview:icon];
    }
    return self;
}

@end
