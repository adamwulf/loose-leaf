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
        [self showDebugBorder];
        CGRect contentFrame = self.bounds;
        contentFrame.origin = CGPointMake(10, 10);
        contentView = [[UIView alloc] initWithFrame:contentFrame];
        contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:contentView];
    }
    return self;
}

-(void) setFrame:(CGRect)frame{
    [super setFrame:[SLShadowedView expandFrame:frame]];
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

+(CGPoint) contentOffset{
    return CGPointMake(10, 10);
}



@end
