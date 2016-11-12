//
//  MMRotatingBackgroundView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 5/4/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMRotatingBackgroundView.h"
#import "UIImage+FXBlur.h"
#import "NSFileManager+DirectoryOptimizations.h"
#import "AVHexColor.h"

static const NSInteger numberOfBackgrounds = 55;
static const CGFloat durationBetweenBackgroundTransitions = 60;
static const CGFloat durationOfTransition = 10;


@implementation MMRotatingBackgroundView {
    UIImageView* visibleBackgroundView;
    UIImageView* fadingBackgroundView;

    NSTimer* delegateTimer;
    NSTimer* transitionTimer;
    NSInteger lastImage;

    // for background color data
    NSDate* lastRenderTime;
    CGFloat ratio;
    NSInteger scaledWidth;
    NSInteger scaledHeight;
    NSInteger bytesPerPixel;
    NSInteger bytesPerRow;

    unsigned char* pixel;
    ;
}

- (UIImage*)imageForNumber:(NSInteger)num {
    NSString* imageToLoad = [NSString stringWithFormat:@"bg%02ld.jpg", (long)num];
    return [UIImage imageNamed:imageToLoad];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        CGFloat parallaxDistance = 100;

        ratio = 100.0 / CGRectGetWidth([self bounds]);
        scaledWidth = 100;
        scaledHeight = floor(ratio * CGRectGetHeight([self bounds]));
        bytesPerPixel = 4;
        bytesPerRow = scaledWidth * bytesPerPixel;
        pixel = calloc(bytesPerRow * scaledHeight, bytesPerPixel);
        lastRenderTime = [NSDate distantPast];

        lastImage = (rand() % numberOfBackgrounds);

        CGRect bufferedFrame = CGRectInset(self.bounds, -parallaxDistance, -parallaxDistance);

        visibleBackgroundView = [[UIImageView alloc] initWithFrame:bufferedFrame];
        visibleBackgroundView.image = [self imageForNumber:lastImage];
        visibleBackgroundView.contentMode = UIViewContentModeScaleAspectFill;
        visibleBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:visibleBackgroundView];

        fadingBackgroundView = [[UIImageView alloc] initWithFrame:bufferedFrame];
        fadingBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        fadingBackgroundView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:fadingBackgroundView];

        visibleBackgroundView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        fadingBackgroundView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));

        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;


        // Set vertical effect
        UIInterpolatingMotionEffect* verticalMotionEffect =
            [[UIInterpolatingMotionEffect alloc]
                initWithKeyPath:@"center.y"
                           type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
        verticalMotionEffect.minimumRelativeValue = @(-parallaxDistance);
        verticalMotionEffect.maximumRelativeValue = @(parallaxDistance);

        // Set horizontal effect
        UIInterpolatingMotionEffect* horizontalMotionEffect =
            [[UIInterpolatingMotionEffect alloc]
                initWithKeyPath:@"center.x"
                           type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
        horizontalMotionEffect.minimumRelativeValue = @(-parallaxDistance);
        horizontalMotionEffect.maximumRelativeValue = @(parallaxDistance);

        // Create group to combine both
        UIMotionEffectGroup* group = [UIMotionEffectGroup new];
        group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];

        // Add both effects to your view
        [self addMotionEffect:group];

        transitionTimer = [NSTimer scheduledTimerWithTimeInterval:durationBetweenBackgroundTransitions target:self selector:@selector(transitionBackground:) userInfo:nil repeats:NO];
    }
    return self;
}

- (void)dealloc {
    free(pixel);
}

- (void)transitionBackground:(id)sender {
    transitionTimer = nil;
    fadingBackgroundView.alpha = 0.0;

    delegateTimer = [NSTimer scheduledTimerWithTimeInterval:durationBetweenBackgroundTransitions / 10 target:self selector:@selector(notifyBackgroundTransition:) userInfo:nil repeats:YES];

    NSInteger nextImage;
    do {
        nextImage = (rand() % numberOfBackgrounds);
    } while (nextImage == lastImage);

    fadingBackgroundView.image = [self imageForNumber:nextImage];

    lastImage = nextImage;

    UIImageView* v = fadingBackgroundView;
    fadingBackgroundView = visibleBackgroundView;
    visibleBackgroundView = v;

    [UIView animateWithDuration:durationOfTransition delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        visibleBackgroundView.alpha = 1;
    } completion:^(BOOL finished) {
        // reset order
        [[self delegate] rotatingBackgroundViewDidUpdate:self];

        fadingBackgroundView.alpha = 0;
        fadingBackgroundView.image = nil;
        [self addSubview:fadingBackgroundView];

        transitionTimer = [NSTimer scheduledTimerWithTimeInterval:durationBetweenBackgroundTransitions target:self selector:@selector(transitionBackground:) userInfo:nil repeats:NO];

        [delegateTimer invalidate];
        delegateTimer = nil;
    }];
}

- (void)notifyBackgroundTransition:(NSTimer*)timer {
    [[self delegate] rotatingBackgroundViewDidUpdate:self];
}

- (void)rerenderToContext {
    if (ABS([lastRenderTime timeIntervalSinceNow]) > 1) {
        lastRenderTime = [NSDate date];

        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(pixel,
                                                     scaledWidth, scaledHeight, 8, bytesPerRow,
                                                     colorSpace,
                                                     (CGBitmapInfo)kCGImageAlphaPremultipliedLast);

        CGContextScaleCTM(context, ratio, ratio);

        [self.layer.presentationLayer renderInContext:context];

        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
    }
}

- (UIColor*)colorFromPoint:(CGPoint)point {
    point.x *= ratio;
    point.y *= ratio;
    point.y = MAX(0, MIN(scaledHeight - 1, point.y));
    point.y = scaledHeight - point.y - 1;

    [self rerenderToContext];

    NSInteger offset = floor(point.x) * bytesPerPixel + floor(point.y) * bytesPerRow;
    UIColor* color = [UIColor colorWithRed:pixel[offset + 0] / 255.0
                                     green:pixel[offset + 1] / 255.0
                                      blue:pixel[offset + 2] / 255.0
                                     alpha:pixel[offset + 3] / 255.0];

    return color;
}

@end
