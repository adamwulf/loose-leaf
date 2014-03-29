//
//  MMSidebarImagePicker.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/27/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMSlidingSidebarView.h"
#import "MMLeftCloseButton.h"
#import "UIView+Animations.h"
#import "MMSlidingSidebarContainerView.h"

@implementation MMSlidingSidebarView{
    // this is the button that'll trigger the sidebar
    MMSidebarButton* referenceButton;
    // this is our button inside the sidebar
    MMLeftCloseButton* closeButton;
    // the width of the strokes in the border
    CGFloat borderSize;
    // YES if we should animate from the left,
    // NO for the right
    BOOL directionIsFromLeft;
}

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame forButton:(MMSidebarButton*)_button animateFromLeft:(BOOL)fromLeft
{
    self = [super initWithFrame:frame];
    if (self) {
        // 2 points for the border size
        borderSize = 2;
        // store our direction and reference button
        directionIsFromLeft = fromLeft;
        referenceButton = _button;
        // make the button we'll use to close
        closeButton = [[MMLeftCloseButton alloc] initWithFrame:referenceButton.frame];
        closeButton.frame = [self rectForButton];
        [closeButton addTarget:self action:@selector(closeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        if(!directionIsFromLeft){
            // flip the button to point to the right
            closeButton.rotation = M_PI;
        }
        [self addSubview:closeButton];
        
        // for clarity
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
    }
    return self;
}

-(BOOL) isVisible{
    return [self.delegate isVisible];
}

// the contentBounds defines what area inside of this view
// is available for the content to be placed. placing content
// outside of this view will probably look very awkward.
//
// the frame of this ContentView lies partially outside of
// the parent view by 1*kBounceWidth. This CGRect calculates
// an area 1*kBounceWidth margin inside of that for content.
-(CGRect) contentBounds{
    CGRect contentBounds = self.bounds;
    contentBounds.size.width -= 2*kBounceWidth;
    if(directionIsFromLeft){
        contentBounds.origin.x = 2*kBounceWidth;
    }else{
        contentBounds.origin.x = kBounceWidth;
        contentBounds.origin.x += referenceButton.frame.size.width;
    }
    contentBounds.size.width -= kBounceWidth;
    contentBounds.size.width -= referenceButton.frame.size.width;
    return contentBounds;
}

// the rectForButton defines where the frame of the button
// will be and is particularly helpful when drawing the
// notch to fit the button in.
-(CGRect) rectForButton{
    CGRect fr = referenceButton.frame;
    if(directionIsFromLeft){
        fr.origin.x = [self contentBounds].origin.x + [self contentBounds].size.width;
        fr.origin.x -= kBounceWidth / 2;
    }else{
        fr.origin.x = [self contentBounds].origin.x - referenceButton.frame.size.width;
        fr.origin.x += kBounceWidth / 2;
    }
    fr.origin.x = ceilf(fr.origin.x);
    fr.origin.y = ceilf(fr.origin.y);
    return fr;
}


#pragma mark - Drawing

// a very dark grey
+(UIColor*) backgroundColor{
    return [UIColor colorWithRed: 0.26 green: 0.26 blue: 0.26 alpha: 0.8];
}

// a semi-opaque white
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
    if(directionIsFromLeft){
        leftDarkArea.size.width += 3*kBounceWidth;
        leftDarkArea.origin.x = 0;
    }else{
        leftDarkArea.origin.x -= kBounceWidth;
        leftDarkArea.size.width += 3*kBounceWidth;
    }
    CGContextSetFillColorWithColor(context, [MMSlidingSidebarView backgroundColor].CGColor);
    CGContextFillRect(context, leftDarkArea);
    
    // right light border line
    CGRect lightBorderLineRect;
    if(directionIsFromLeft){
        lightBorderLineRect = CGRectMake(leftDarkArea.size.width, 0, borderSize, leftDarkArea.size.height);
    }else{
        lightBorderLineRect = CGRectMake(leftDarkArea.origin.x - borderSize, 0, borderSize, leftDarkArea.size.height);
    }
    CGContextSetFillColorWithColor(context, [MMSlidingSidebarView lightBackgroundColor].CGColor);
    CGContextFillRect(context, lightBorderLineRect);
    
    // clip light border circle section
    CGRect circleCrop = CGRectInset([self rectForButton], borderSize, borderSize);
    UIBezierPath* circleCropPath = [UIBezierPath bezierPathWithOvalInRect:circleCrop];
    [self erase:circleCropPath atContext:context];
    // draw curved light border
    [[MMSlidingSidebarView lightBackgroundColor] setFill];
    [circleCropPath fill];

    // clip dark border circle section
    CGRect innerCircleCrop = CGRectInset(circleCrop, borderSize, borderSize);
    UIBezierPath* innerCircleCropPath = [UIBezierPath bezierPathWithOvalInRect:innerCircleCrop];
    [self erase:innerCircleCropPath atContext:context];
    // draw dark curved border
    [[MMSlidingSidebarView backgroundColor] setFill];
    [innerCircleCropPath fill];

    // right dark border line
    CGRect darkBorderLineRect;
    if(directionIsFromLeft){
        darkBorderLineRect = CGRectMake(leftDarkArea.size.width + borderSize, 0, borderSize, leftDarkArea.size.height);
    }else{
        darkBorderLineRect = CGRectMake(leftDarkArea.origin.x - borderSize*2, 0, borderSize, leftDarkArea.size.height);
    }
    // fill right border
    UIBezierPath* stripeRRectPath = [UIBezierPath bezierPathWithRect:darkBorderLineRect];
    [self erase:stripeRRectPath atContext:context];
    [[MMSlidingSidebarView backgroundColor] setFill];
    [stripeRRectPath fill];

    // clip where the button will rest
    CGRect buttonCircleCrop = CGRectInset(innerCircleCrop, borderSize, borderSize);
    UIBezierPath* buttonCircleCropPath = [UIBezierPath bezierPathWithOvalInRect:buttonCircleCrop];
    [self erase:buttonCircleCropPath atContext:context];
    
    CGRect outsideOfSidebarRect;
    if(directionIsFromLeft){
        // clip everything to the right of our border
        outsideOfSidebarRect = CGRectMake(darkBorderLineRect.origin.x + darkBorderLineRect.size.width, 0,
                                          referenceButton.bounds.size.width, self.bounds.size.height);
    }else{
        outsideOfSidebarRect = CGRectMake(0, 0,darkBorderLineRect.origin.x, self.bounds.size.height);
    }
    UIBezierPath* outsideOfSidebarPath = [UIBezierPath bezierPathWithRect:outsideOfSidebarRect];
    [self erase:outsideOfSidebarPath atContext:context];
}

// helper function to erase everything
// inside of the input path
-(void) erase:(UIBezierPath*)path atContext:(CGContextRef)context{
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [path fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);
}

#pragma mark - Button Bounce Animation

- (void)bounceAnimationForButtonWithDuration:(CGFloat)animationDuration{
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    bounceAnimation.removedOnCompletion = YES;
    
    // the start and end of the animation will be where ever the
    // button already is
    CGPoint startP = closeButton.layer.position;

    // times to change direction. the 0->0.5 only helps to
    // delay when the button starts to slide away from
    // the sidebar during the animation
    bounceAnimation.keyTimes = [NSArray arrayWithObjects:
                                [NSNumber numberWithFloat:0.0],
                                [NSNumber numberWithFloat:0.5],
                                [NSNumber numberWithFloat:0.8],
                                [NSNumber numberWithFloat:0.95],
                                [NSNumber numberWithFloat:1.0], nil];
    if(directionIsFromLeft){
        // from left, bounce to the right
        bounceAnimation.values = [NSArray arrayWithObjects:
                                  [NSValue valueWithCGPoint:startP],
                                  [NSValue valueWithCGPoint:startP],
                                  [NSValue valueWithCGPoint:CGPointMake(startP.x + kBounceWidth/2, startP.y)],
                                  [NSValue valueWithCGPoint:CGPointMake(startP.x - kBounceWidth/5, startP.y)],
                                  [NSValue valueWithCGPoint:startP], nil];
    }else{
        // from right, bounce to the left
        bounceAnimation.values = [NSArray arrayWithObjects:
                                  [NSValue valueWithCGPoint:startP],
                                  [NSValue valueWithCGPoint:startP],
                                  [NSValue valueWithCGPoint:CGPointMake(startP.x - kBounceWidth/2, startP.y)],
                                  [NSValue valueWithCGPoint:CGPointMake(startP.x + kBounceWidth/5, startP.y)],
                                  [NSValue valueWithCGPoint:startP], nil];
    }
    bounceAnimation.timingFunctions = [NSArray arrayWithObjects:
                                       [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
                                       [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
                                       [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                       [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn], nil];
    bounceAnimation.duration = animationDuration;

    [closeButton.layer addAnimation:bounceAnimation forKey:@"bounceAnimation"];
}



#pragma mark - UIButton Event

// tell our delegate to close us down
-(void) closeButtonTapped:(UIButton*)button{
    [self.delegate sidebarCloseButtonWasTapped];
}


@end
