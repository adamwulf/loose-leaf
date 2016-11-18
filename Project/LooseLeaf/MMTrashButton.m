//
//  MMTrashButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/23/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMTrashButton.h"
#import "Constants.h"
#import "UIView+Animations.h"


@implementation MMTrashButton


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
    }
    return self;
}

- (void)bounceButton:(id)sender {
    if (self.enabled) {
        self.center = self.center;
        [self bounceWithTransform:[self rotationTransform] stepOne:kMaxButtonBounceHeight / 2 stepTwo:kMinButtonBounceHeight / 2];
    }
}

- (UIColor*)backgroundColor {
    return [UIColor colorWithRed:1 green:1 blue:1 alpha:0.502];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat smallest = MIN(self.bounds.size.width, self.bounds.size.height);
    CGFloat drawingWidth = (smallest - 2 * kWidthOfSidebarButtonBuffer);
    CGRect frame = CGRectMake(kWidthOfSidebarButtonBuffer, kWidthOfSidebarButtonBuffer, drawingWidth, drawingWidth);

    //// Color Declarations
    UIColor* darkerGreyBorder = [self borderColor];
    UIColor* halfGreyFill = [self backgroundColor];

    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 0.5, floor(CGRectGetWidth(frame) - 1.0), floor(CGRectGetHeight(frame) - 1.0))];
    [halfGreyFill setFill];
    [ovalPath fill];

    ovalPath.lineWidth = 1;
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setStroke];
    [ovalPath stroke];
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    [darkerGreyBorder setStroke];
    [ovalPath stroke];


    frame = CGRectInset(frame, 2, 2);
    frame.origin.y += 1;

    [MMTrashButton drawTrashCanInRect:frame withColor:[UIColor darkGrayColor] withBackground:nil];

    [super drawRect:rect];
}

+ (UIImage*)trashIconWithColor:(UIColor*)color {
    UIColor* halfGreyFill = [UIColor colorWithRed:0.84 green:0.84 blue:0.84 alpha:0.5];
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(30, 40), NO, 0);
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), -8, 0);
    [MMTrashButton drawTrashCanInRect:CGRectMake(0, 0, 40, 40) withColor:color withBackground:halfGreyFill];
    UIImage* trashImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return trashImg;
}

+ (void)drawTrashCanInRect:(CGRect)frame withColor:(UIColor*)strokeColor withBackground:(UIColor*)backgroundColor {
    CGFloat trueWidth = CGRectGetWidth(frame);
    CGFloat lineWidth = trueWidth / 100.0 * 2.0;

    if (backgroundColor) {
        UIBezierPath* trashOutlinePath = [UIBezierPath bezierPath];
        [trashOutlinePath moveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.52001 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.20001 * CGRectGetHeight(frame))];
        [trashOutlinePath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.54000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.22000 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.52000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.20000 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.54000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.22000 * CGRectGetHeight(frame))];
        [trashOutlinePath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.77000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.22000 * CGRectGetHeight(frame))];
        [trashOutlinePath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.78000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25000 * CGRectGetHeight(frame))];
        [trashOutlinePath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.74000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25000 * CGRectGetHeight(frame))];
        [trashOutlinePath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.73500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.29000 * CGRectGetHeight(frame))];
        [trashOutlinePath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.66500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.80000 * CGRectGetHeight(frame))];
        [trashOutlinePath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.33500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.80000 * CGRectGetHeight(frame))];
        [trashOutlinePath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.26500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.29000 * CGRectGetHeight(frame))];
        [trashOutlinePath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.26500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25000 * CGRectGetHeight(frame))];
        [trashOutlinePath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.22000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25000 * CGRectGetHeight(frame))];
        [trashOutlinePath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.23000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.22000 * CGRectGetHeight(frame))];
        [trashOutlinePath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.43996 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.22000 * CGRectGetHeight(frame))];
        [trashOutlinePath addCurveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.46000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.20000 * CGRectGetHeight(frame)) controlPoint1:CGPointMake(CGRectGetMinX(frame) + 0.44000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.22000 * CGRectGetHeight(frame)) controlPoint2:CGPointMake(CGRectGetMinX(frame) + 0.46000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.20000 * CGRectGetHeight(frame))];
        [trashOutlinePath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.51999 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.20000 * CGRectGetHeight(frame))];
        [trashOutlinePath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.52001 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.20001 * CGRectGetHeight(frame))];
        [trashOutlinePath closePath];

        [backgroundColor setFill];
        [trashOutlinePath fill];
    }

    //// trash can Drawing
    UIBezierPath* trashCanPath = [UIBezierPath bezierPath];
    [trashCanPath moveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.27000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34000 * CGRectGetHeight(frame))];
    [trashCanPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.26000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34000 * CGRectGetHeight(frame))];
    [trashCanPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.25000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.28000 * CGRectGetHeight(frame))];
    [trashCanPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.26500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.28000 * CGRectGetHeight(frame))];
    [trashCanPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.33500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.79000 * CGRectGetHeight(frame))];
    [trashCanPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.66500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.79000 * CGRectGetHeight(frame))];
    [trashCanPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.73500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.28000 * CGRectGetHeight(frame))];
    [trashCanPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.75000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.28000 * CGRectGetHeight(frame))];
    [trashCanPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.74000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34000 * CGRectGetHeight(frame))];
    [trashCanPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.73000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34000 * CGRectGetHeight(frame))];
    [strokeColor setStroke];
    trashCanPath.lineWidth = lineWidth;
    [trashCanPath stroke];


    //// detail line 2 Drawing
    UIBezierPath* detailLine2Path = [UIBezierPath bezierPath];
    [detailLine2Path moveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.50000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.28000 * CGRectGetHeight(frame))];
    [detailLine2Path addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.50000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.74500 * CGRectGetHeight(frame))];
    [strokeColor setStroke];
    detailLine2Path.lineWidth = lineWidth;
    [detailLine2Path stroke];


    //// detail line 3 Drawing
    UIBezierPath* detailLine3Path = [UIBezierPath bezierPath];
    [detailLine3Path moveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.63000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.28000 * CGRectGetHeight(frame))];
    [detailLine3Path addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.59500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.74500 * CGRectGetHeight(frame))];
    [strokeColor setStroke];
    detailLine3Path.lineWidth = lineWidth;
    [detailLine3Path stroke];


    //// detail line 1 Drawing
    UIBezierPath* detailLine1Path = [UIBezierPath bezierPath];
    [detailLine1Path moveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.37000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.28000 * CGRectGetHeight(frame))];
    [detailLine1Path addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.40500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.74500 * CGRectGetHeight(frame))];
    [strokeColor setStroke];
    detailLine1Path.lineWidth = lineWidth;
    [detailLine1Path stroke];


    //// trash lid Drawing
    UIBezierPath* trashLidPath = [UIBezierPath bezierPath];
    [trashLidPath moveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.23000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.22000 * CGRectGetHeight(frame))];
    [trashLidPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.44000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.22000 * CGRectGetHeight(frame))];
    [trashLidPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.46000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.20000 * CGRectGetHeight(frame))];
    [trashLidPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.52000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.20000 * CGRectGetHeight(frame))];
    [trashLidPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.54000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.22000 * CGRectGetHeight(frame))];
    [trashLidPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.77000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.22000 * CGRectGetHeight(frame))];
    [trashLidPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.78000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25000 * CGRectGetHeight(frame))];
    [trashLidPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.22000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25000 * CGRectGetHeight(frame))];
    [trashLidPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.23000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.22000 * CGRectGetHeight(frame))];
    [trashLidPath closePath];
    [strokeColor setStroke];
    trashLidPath.lineWidth = lineWidth;
    [trashLidPath stroke];
}

@end
