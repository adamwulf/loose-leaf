//
//  MMSidebarImagePicker.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/27/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMSidebarImagePicker.h"
#import "MMLeftCloseButton.h"

@implementation MMSidebarImagePicker{
    MMBounceButton* referenceButton;
    MMLeftCloseButton* closeButton;
    CGFloat borderSize;
}

- (id)initWithFrame:(CGRect)frame forButton:(MMBounceButton*)_button
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
        [self addSubview:closeButton];
    }
    return self;
}

-(CGRect) rectForButton{
    CGRect fr = closeButton.frame;
    fr.origin.x = [self contentBounds].size.width;
    fr.origin.x -= [closeButton drawableFrame].size.width * 2 / 5;
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


-(CGRect) contentBounds{
    CGRect contentBounds = self.bounds;
    contentBounds.size.width -= referenceButton.frame.size.width;
    return contentBounds;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    CGRect contentBounds = [self contentBounds];
    
    
    CGRect stripeLRect = CGRectMake(contentBounds.size.width, 0, borderSize/2, contentBounds.size.height);
    CGRect stripeRRect = CGRectMake(contentBounds.size.width + borderSize/2, 0, borderSize/2, contentBounds.size.height);
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [MMSidebarImagePicker backgroundColor].CGColor);
    CGContextFillRect(context, contentBounds);

    CGContextSetFillColorWithColor(context, [MMSidebarImagePicker lightBackgroundColor].CGColor);
    CGContextFillRect(context, stripeLRect);
    
    
    CGRect circleCrop = CGRectInset([self rectForButton], borderSize/2, borderSize/2);
    UIBezierPath* circleCropPath = [UIBezierPath bezierPathWithOvalInRect:circleCrop];

    CGRect innerCircleCrop = CGRectInset(circleCrop, borderSize/2, borderSize/2);
    UIBezierPath* innerCircleCropPath = [UIBezierPath bezierPathWithOvalInRect:innerCircleCrop];

    CGRect buttonCircleCrop = CGRectInset(innerCircleCrop, borderSize/2, borderSize/2);
    UIBezierPath* buttonCircleCropPath = [UIBezierPath bezierPathWithOvalInRect:buttonCircleCrop];

    
    // clear the circle
    [self erase:circleCropPath atContext:context];

    // draw curved light border
    [[MMSidebarImagePicker lightBackgroundColor] setFill];
    [circleCropPath fill];
    
    // clip dark border section
    [self erase:innerCircleCropPath atContext:context];
    
    // draw dark curved border
    [[MMSidebarImagePicker backgroundColor] setFill];
    [innerCircleCropPath fill];
    

    // fill right border
    UIBezierPath* stripeRRectPath = [UIBezierPath bezierPathWithRect:stripeRRect];
    [[MMSidebarImagePicker backgroundColor] setFill];
    [stripeRRectPath fill];
    
    
    // clip where the button will rest
    [self erase:buttonCircleCropPath atContext:context];
    
    // clip to the right of our border
    UIBezierPath* rightOfBorderPath = [UIBezierPath bezierPathWithRect:CGRectMake(stripeRRect.origin.x + stripeRRect.size.width, 0,
                                                                                  referenceButton.bounds.size.width, self.bounds.size.height)];
    [self erase:rightOfBorderPath atContext:context];
    

}


-(void) erase:(UIBezierPath*)path atContext:(CGContextRef)context{
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [path fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);
}


@end
