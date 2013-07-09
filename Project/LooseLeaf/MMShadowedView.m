//
//  MMShadowedView.m
//  Loose Leaf
//
//  Created by Adam Wulf on 7/5/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "MMShadowedView.h"
#import "UIView+Debug.h"
#import "Constants.h"
#import "UIColor+Shadow.h"
#import <QuartzCore/QuartzCore.h>

@implementation MMShadowedView

@synthesize contentView;

+(CGRect) expandFrame:(CGRect)rect{
    return CGRectMake(rect.origin.x - 10, rect.origin.y - 10, rect.size.width + 20, rect.size.height + 20);
}
+(CGRect) contractFrame:(CGRect)rect{
    return CGRectMake(rect.origin.x + 10, rect.origin.y + 10, rect.size.width - 20, rect.size.height - 20);
}
+(CGRect) expandBounds:(CGRect)rect{
    return CGRectMake(rect.origin.x, rect.origin.y, rect.size.width + 20, rect.size.height + 20);
}
+(CGRect) contractBounds:(CGRect)rect{
    return CGRectMake(rect.origin.x, rect.origin.y, rect.size.width - 20, rect.size.height - 20);
}

+(CGFloat) shadowWidth{
    return 10;
}


- (id)initWithFrame:(CGRect)frame
{
    //
    // this'll call our setFrame, so it'll be adjusted in a super call
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CGRect contentFrame = self.bounds;
        // since our frame has been adjusted, we need to offset the
        // content view appropriately inside of our adjusted frame
        contentFrame.origin = CGPointMake(10, 10);
        contentView = [[UIView alloc] initWithFrame:contentFrame];
        contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.opaque = NO;
        self.clipsToBounds = YES;
        
        
        UIColor* clear = [UIColor clearColor];
        UIColor* white = [UIColor whiteColor];
        UIColor* shadowColor = [UIColor shadowColor];
        
        
        contentView.opaque = YES;
        contentView.backgroundColor = white;
        contentView.clipsToBounds = YES;
        
        self.backgroundColor = clear;
        [self addSubview:contentView];

        self.layer.shadowPath = [UIBezierPath bezierPathWithRect:contentView.frame].CGPath;
        self.layer.shadowRadius = 4;
        self.layer.shadowColor = shadowColor.CGColor;
        self.layer.shadowOpacity = 1;
        self.layer.shadowOffset = CGSizeMake(0, 0);
    }
    return self;
}


/**
 * whenever the frame changes (from a scale)
 * we should update our shadow path to match
 *
 * note that while the frame can be animated, the 
 * shadow path needs its own CABasicAnimation to
 * animate. it won't piggy back on the frame
 * animation
 */
-(void) setFrame:(CGRect)frame{
    CGRect expandedFrame = [MMShadowedView expandFrame:frame];
    [super setFrame:expandedFrame];
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:contentView.frame].CGPath;
}

-(CGRect) frame{
    CGRect fr = [super frame];
    return [MMShadowedView contractFrame:fr];
}

-(CGRect) bounds{
    CGRect bounds = [MMShadowedView contractBounds:[super bounds]];
    return bounds;
}
-(void) setBounds:(CGRect)bounds{
    [super setBounds:[MMShadowedView expandBounds:bounds]];
}


@end
