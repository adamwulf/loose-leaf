//
//  SLShadowedView.m
//  scratchpaper
//
//  Created by Adam Wulf on 7/5/12.
//
//

#import "SLShadowedView.h"
#import "UIView+Debug.h"
#import "Constants.h"
#import <QuartzCore/QuartzCore.h>

@implementation SLShadowedView

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


- (id)initWithFrame:(CGRect)frame
{
    //
    // this'll call our setFrame, so it'll be adjusted
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CGRect contentFrame = self.bounds;
        contentFrame.origin = CGPointMake(10, 10);
        contentView = [[UIView alloc] initWithFrame:contentFrame];
        contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.opaque = NO;
        self.clipsToBounds = YES;
        
        contentView.opaque = YES;
        contentView.backgroundColor = [UIColor whiteColor];
        contentView.clipsToBounds = NO;
        
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:contentView];

        contentView.layer.shadowPath = [UIBezierPath bezierPathWithRect:contentView.bounds].CGPath;
        contentView.layer.shadowRadius = 5;
        contentView.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:.5].CGColor;
        contentView.layer.shadowOpacity = 1;
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
    [super setFrame:[SLShadowedView expandFrame:frame]];
    contentView.layer.shadowPath = [UIBezierPath bezierPathWithRect:contentView.bounds].CGPath;
}

-(CGRect) frame{
    CGRect fr = [super frame];
    return [SLShadowedView contractFrame:fr];
}

-(CGRect) bounds{
    CGRect bounds = [SLShadowedView contractBounds:[super bounds]];
    return bounds;
}
-(void) setBounds:(CGRect)bounds{
    [super setBounds:[SLShadowedView expandBounds:bounds]];
}


@end
