//
//  MMScrapBubbleView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/26/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMScrapBubbleView.h"
#import "MMScrapBorderView.h"
#import "DrawKit-iOS.h"

@implementation MMScrapBubbleView{
    CGFloat rotationAdjustment;
    MMScrapBorderView* borderView;
}

@synthesize scrap;
@synthesize rotation;
@synthesize scale;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        rotationAdjustment = 0;
        rotation = 0;
        scale = 1;
        borderView = [[MMScrapBorderView alloc] initWithFrame:self.bounds];
        [self addSubview:borderView];
    }
    return self;
}

#pragma mark - Rotation

-(void) setRotation:(CGFloat)_rotation{
    rotation = _rotation;
    self.transform = CGAffineTransformMakeScale(scale, scale);
//    self.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(rotation - rotationAdjustment), scale, scale);
}

-(void) setScale:(CGFloat)_scale{
    scale = _scale;
    self.transform = CGAffineTransformMakeScale(scale, scale);
//    self.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(rotation - rotationAdjustment), scale, scale);
}

#pragma mark - Scrap

+(CGAffineTransform) idealTransformForScrap:(MMScrapView*)scrap{
    CGFloat scale = 36.0 / MAX(scrap.originalBounds.size.width, scrap.originalBounds.size.height);
    return CGAffineTransformConcat(CGAffineTransformMakeRotation(scrap.rotation),CGAffineTransformMakeScale(scale, scale));
}

-(void) setScrap:(MMScrapView *)_scrap{
    scrap = _scrap;
    rotationAdjustment = rotation;
    self.rotation = rotation; // force transform update

    [self insertSubview:scrap belowSubview:borderView];
    scrap.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    scrap.transform = [MMScrapBubbleView idealTransformForScrap:scrap];
    UIBezierPath* path = [scrap.bezierPath copy];
    [path applyTransform:scrap.transform];
    
    CGFloat centerX = (self.bounds.size.width - path.bounds.size.width) / 2;
    CGFloat centerY = (self.bounds.size.height - path.bounds.size.height) / 2;
    NSLog(@"scrap %f %f", centerX, centerY);
    NSLog(@"path %f %f", path.bounds.origin.x, path.bounds.origin.y);
    CGFloat diffX = centerX - path.bounds.origin.x;
    CGFloat diffY = centerY - path.bounds.origin.y;
    
    
    
    
    CGPoint firstscrappoint = [scrap firstPoint];
    firstscrappoint = [self convertPoint:firstscrappoint fromView:scrap];
    NSLog(@"scrap first %f %f", firstscrappoint.x, firstscrappoint.y);
    CGPoint firstpathpoint = [path elementAtIndex:0].points[0];
    NSLog(@"path %f %f", firstpathpoint.x, firstpathpoint.y);
    
    diffX = firstscrappoint.x - firstpathpoint.x;
    diffY = firstscrappoint.y - firstpathpoint.y;

    
    [path applyTransform:CGAffineTransformMakeTranslation(diffX, diffY)];
    NSLog(@"path %f %f", path.bounds.origin.x, path.bounds.origin.y);
    NSLog(@"scrap %f %f", scrap.center.x, scrap.center.y);
    NSLog(@"path %f %f", path.bounds.origin.x + path.bounds.size.width/2, path.bounds.origin.y + path.bounds.size.height / 2);
    
    
    
    [borderView setBezierPath:path];
}


#pragma mark - Properties


-(UIColor*) borderColor{
    return [UIColor colorWithRed: 0.26 green: 0.26 blue: 0.26 alpha: 0.35];
}

-(UIColor*) backgroundColor{
    return [UIColor colorWithRed: 0.84 green: 0.84 blue: 0.84 alpha: 0.5];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGRect shadowFrame = CGRectInset(self.bounds, 10, 10);
    CGFloat tokenAdjustment = (100 - self.bounds.size.width) / 15;
    CGRect tokenFrame = CGRectInset(self.bounds, 14 - tokenAdjustment, 14 - tokenAdjustment);
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect:shadowFrame];
    UIBezierPath* tokenOvalPath = [UIBezierPath bezierPathWithOvalInRect:tokenFrame];
    
    
    [[self backgroundColor] setFill];
    [tokenOvalPath fill];

    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setStroke];
    tokenOvalPath.lineWidth = 1;
    [tokenOvalPath stroke];
    CGContextSetBlendMode(context, kCGBlendModeNormal);

    [[self borderColor] setStroke];
    [tokenOvalPath stroke];
    
    
    
    
    
    //
    //
    // shadow
    //
    
    UIColor* greyShadowColor = [self borderColor];
    
    //
    // possible drop shadow
    UIColor* gradientColor = [greyShadowColor colorWithAlphaComponent:0.5];
    UIColor* clearColor = [greyShadowColor colorWithAlphaComponent:0];
    NSArray* gradientColors = [NSArray arrayWithObjects:
                               (id)gradientColor.CGColor,
                               (id)clearColor.CGColor, nil];
    CGFloat gradientLocations[] = {0, 1};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, gradientLocations);
    CGContextSaveGState(context);
    
    UIBezierPath* clipPath = [ovalPath copy];
    [clipPath appendPath:[UIBezierPath bezierPathWithRect:CGRectInfinite]];
    clipPath.usesEvenOddFillRule = YES;
    [clipPath addClip];
    
    CGContextDrawRadialGradient(context, gradient,
                                CGPointMake(CGRectGetMidX(shadowFrame), CGRectGetMidY(shadowFrame)), shadowFrame.size.width / 2 - 1,
                                CGPointMake(CGRectGetMidX(shadowFrame), CGRectGetMidY(shadowFrame)), shadowFrame.size.width / 2 + 4.5 * shadowFrame.size.width / 100.0,
                                kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    
    CGContextRestoreGState(context);

}


@end
