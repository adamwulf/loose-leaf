//
//  MMSidebarImagePicker.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/27/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMSidebarImagePicker.h"
#import "MMLeftCloseButton.h"
#import "UIView+Animations.h"

@implementation MMSidebarImagePicker{
    MMSidebarButton* referenceButton;
    MMLeftCloseButton* closeButton;
    CGFloat borderSize;
}

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame forButton:(MMSidebarButton*)_button
{
    self = [super initWithFrame:frame];
    if (self) {
        borderSize = 4;
        
        referenceButton = _button;
        // Initialization code
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        closeButton = [[MMLeftCloseButton alloc] initWithFrame:referenceButton.frame];
        closeButton.frame = [self rectForButton];
        [closeButton addTarget:self action:@selector(closeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
    }
    return self;
}

-(void) closeButtonTapped:(UIButton*)button{
    [self.delegate sidebarCloseButtonWasTapped];
}


-(CGRect) contentBounds{
    CGRect contentBounds = self.bounds;
    contentBounds.origin.x = 2*kBounceWidth;
    contentBounds.size.width -= 2*kBounceWidth;
    contentBounds.size.width -= [referenceButton drawableFrame].size.width;
    return contentBounds;
}

-(CGRect) rectForButton{
    CGRect fr = referenceButton.frame;
    fr.origin.x = [self contentBounds].origin.x + [self contentBounds].size.width;
    fr.origin.x -= kBounceWidth;
    fr.origin.x -= [referenceButton drawableFrame].size.width * 2 / 5;
    fr.origin.y = ceilf(fr.origin.y);
    fr.origin.x = ceilf(fr.origin.x);
    return fr;
}


#pragma mark - Colors

+(UIColor*) backgroundColor{
    return [UIColor colorWithRed: 0.26 green: 0.26 blue: 0.26 alpha: 0.8];
}

+(UIColor*) lightBackgroundColor{
    return [UIColor colorWithRed: 0.84 green: 0.84 blue: 0.84 alpha: 0.5];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();

    // draw the dark background for the sidebar
    CGRect leftDarkArea = [self contentBounds];
    leftDarkArea.origin.x = 0;
    leftDarkArea.size.width += kBounceWidth;
    CGContextSetFillColorWithColor(context, [MMSidebarImagePicker backgroundColor].CGColor);
    CGContextFillRect(context, leftDarkArea);
    
    // right light border line
    CGRect lightBorderLineRect = CGRectMake(leftDarkArea.size.width, 0, borderSize/2, leftDarkArea.size.height);
    CGContextSetFillColorWithColor(context, [MMSidebarImagePicker lightBackgroundColor].CGColor);
    CGContextFillRect(context, lightBorderLineRect);
    
    // clip light border circle section
    CGRect circleCrop = CGRectInset([self rectForButton], borderSize/2, borderSize/2);
    UIBezierPath* circleCropPath = [UIBezierPath bezierPathWithOvalInRect:circleCrop];
    [self erase:circleCropPath atContext:context];
    // draw curved light border
    [[MMSidebarImagePicker lightBackgroundColor] setFill];
    [circleCropPath fill];

    // clip dark border circle section
    CGRect innerCircleCrop = CGRectInset(circleCrop, borderSize/2, borderSize/2);
    UIBezierPath* innerCircleCropPath = [UIBezierPath bezierPathWithOvalInRect:innerCircleCrop];
    [self erase:innerCircleCropPath atContext:context];
    // draw dark curved border
    [[MMSidebarImagePicker backgroundColor] setFill];
    [innerCircleCropPath fill];

    // right dark border line
    CGRect darkBorderLineRect = CGRectMake(leftDarkArea.size.width + borderSize/2, 0, borderSize/2, leftDarkArea.size.height);
    // fill right border
    UIBezierPath* stripeRRectPath = [UIBezierPath bezierPathWithRect:darkBorderLineRect];
    [self erase:stripeRRectPath atContext:context];
    [[MMSidebarImagePicker backgroundColor] setFill];
    [stripeRRectPath fill];

    // clip where the button will rest
    CGRect buttonCircleCrop = CGRectInset(innerCircleCrop, borderSize/2, borderSize/2);
    UIBezierPath* buttonCircleCropPath = [UIBezierPath bezierPathWithOvalInRect:buttonCircleCrop];
    [self erase:buttonCircleCropPath atContext:context];
    
    // clip everything to the right of our border
    CGRect rightOfSidebarRect = CGRectMake(darkBorderLineRect.origin.x + darkBorderLineRect.size.width, 0,
                                           referenceButton.bounds.size.width, self.bounds.size.height);
    UIBezierPath* rightOfBorderPath = [UIBezierPath bezierPathWithRect:rightOfSidebarRect];
    [self erase:rightOfBorderPath atContext:context];
    

}

- (void)bounceAnimationForButtonWithDuration:(CGFloat)duration{
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    bounceAnimation.removedOnCompletion = YES;
    
    CGPoint startP = closeButton.layer.position;

    bounceAnimation.keyTimes = [NSArray arrayWithObjects:
                                [NSNumber numberWithFloat:0.0],
                                [NSNumber numberWithFloat:0.5],
                                [NSNumber numberWithFloat:0.8],
                                [NSNumber numberWithFloat:0.95],
                                [NSNumber numberWithFloat:1.0], nil];
    bounceAnimation.values = [NSArray arrayWithObjects:
                              [NSValue valueWithCGPoint:startP],
                              [NSValue valueWithCGPoint:startP],
                              [NSValue valueWithCGPoint:CGPointMake(startP.x + kBounceWidth/2, startP.y)],
                              [NSValue valueWithCGPoint:CGPointMake(startP.x - kBounceWidth/5, startP.y)],
                              [NSValue valueWithCGPoint:startP], nil];
    bounceAnimation.timingFunctions = [NSArray arrayWithObjects:
                                       [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
                                       [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
                                       [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                       [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn], nil];
    bounceAnimation.duration = duration;

    [closeButton.layer addAnimation:bounceAnimation forKey:@"bounceAnimation"];
}


-(void) erase:(UIBezierPath*)path atContext:(CGContextRef)context{
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [path fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);
}


@end
