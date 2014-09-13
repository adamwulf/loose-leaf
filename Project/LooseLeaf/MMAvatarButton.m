//
//  MMAvatarButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/27/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMAvatarButton.h"
#import <CoreText/CoreText.h>
#import "Constants.h"
#import "NSThread+BlockAdditions.h"
#import "UIFont+UIBezierCurve.h"

@implementation MMAvatarButton{
    NSString* letter;
    CGPoint offset;
    CGFloat pointSize;
    CTFontSymbolicTraits traits;
    UIFont* font;
    
    CGFloat targetProgress;
    BOOL targetSuccess;
    CGFloat lastProgress;
    CGFloat lastRadius;
}

@synthesize targetSuccess;
@synthesize targetProgress;

- (id)initWithFrame:(CGRect)_frame forLetter:(NSString*)_letter andOffset:(CGPoint)_offset{
    self = [super initWithFrame:_frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        offset = _offset;
        letter = _letter;
        font = [UIFont systemFontOfSize:16];
        pointSize = [font pointSize] * kWidthOfSidebarButton / 50.0;
    }
    return self;
}


- (id)initWithFrame:(CGRect)_frame forLetter:(NSString*)_letter{
    return [self initWithFrame:_frame forLetter:_letter andOffset:CGPointZero];
}

-(UIColor*) backgroundColor{
    if(self.shouldDrawDarkBackground){
        return [UIColor colorWithRed:.4 green:.4 blue:.4 alpha:.9];
    }else{
        return [[UIColor whiteColor] colorWithAlphaComponent:.7];
    }
}

-(UIColor*) fontColor{
    if(self.shouldDrawDarkBackground){
        return [[UIColor whiteColor] colorWithAlphaComponent:.7];
    }else{
        return [self borderColor];
    }
}

-(NSString*) letter{
    return letter;
}

-(void) setLetter:(NSString *)_letter{
    letter = _letter;
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat smallest = MIN(self.bounds.size.width, self.bounds.size.height);
    CGFloat drawingWidth = (smallest - 2*kWidthOfSidebarButtonBuffer);
    CGRect frame = CGRectMake(kWidthOfSidebarButtonBuffer, kWidthOfSidebarButtonBuffer, drawingWidth, drawingWidth);
    CGFloat scaledPointSize = drawingWidth * pointSize / (kWidthOfSidebarButton - 2*kWidthOfSidebarButtonBuffer);
    
    //// Color Declarations
    UIColor* darkerGreyBorder = [self borderColor];
    UIColor* halfGreyFill = [self backgroundColor];
    
    
    CGContextSaveGState(context);
    
    
    UIBezierPath* glyphPath = [[font fontWithSize:scaledPointSize] bezierPathForString:letter];
    CGRect glyphRect = [glyphPath bounds];
    if(!CGRectIsNull(glyphRect) && !CGRectIsEmpty(glyphRect)){
        // if the glyphPath is empty (possibly b/c letter is @"")
        // then we shouldn't draw the path
        glyphRect = glyphPath.bounds;
        CGFloat maxTextWidth = self.drawableFrame.size.width - 10;
        if(glyphRect.size.width > maxTextWidth){
            CGFloat ratio = maxTextWidth / glyphRect.size.width;
            [glyphPath applyTransform:CGAffineTransformMakeScale(ratio, ratio)];
            glyphRect = glyphPath.bounds;
            [glyphPath applyTransform:CGAffineTransformMakeTranslation(-glyphRect.origin.x, -glyphRect.origin.y)];
            glyphRect = glyphPath.bounds;
        }
        
        [glyphPath applyTransform:CGAffineTransformConcat(CGAffineTransformMakeTranslation(-glyphRect.origin.x - .5, -glyphRect.size.height),
                                                          CGAffineTransformMakeScale(1.f, -1.f))];
        [glyphPath applyTransform:CGAffineTransformMakeTranslation((drawingWidth - glyphRect.size.width) / 2 + kWidthOfSidebarButtonBuffer + offset.x,
                                                                   (drawingWidth - glyphRect.size.height) / 2 + kWidthOfSidebarButtonBuffer + offset.y)];
    }else{
        glyphPath = nil;
    }

    //// Oval Drawing
    
    CGRect ovalFrame = CGRectMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 0.5, floor(CGRectGetWidth(frame) - 1.0), floor(CGRectGetHeight(frame) - 1.0));
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect:ovalFrame];
    if(glyphPath){
        [ovalPath appendPath:glyphPath];
    }
    [ovalPath closePath];
    [halfGreyFill setFill];
    [ovalPath fill];
    
    [darkerGreyBorder setStroke];
    ovalPath.lineWidth = 1;
    [ovalPath stroke];
    
    if(self.shouldDrawDarkBackground){
        UIBezierPath* stripe = [UIBezierPath bezierPathWithOvalInRect:ovalFrame];
        CGContextSetBlendMode(context, kCGBlendModeClear);
        [[UIColor whiteColor] setStroke];
        [stripe stroke];
        CGContextSetBlendMode(context, kCGBlendModeNormal);
        [[self fontColor] setStroke];
        [stripe stroke];
    }

    
    if(glyphPath){
        //
        // clear the arrow and box, then fill with
        // border color
        CGContextSetBlendMode(context, kCGBlendModeClear);
        [[UIColor whiteColor] setFill];
        [glyphPath fill];
        CGContextSetBlendMode(context, kCGBlendModeNormal);
        
        [[self fontColor] setFill];
        [glyphPath fill];
    }
    
    CGContextRestoreGState(context);
}


-(void) animateOffScreenWithCompletion:(void (^)(BOOL finished))completion{
    CGPoint offscreen = CGPointMake(self.center.x, self.center.y - self.bounds.size.height / 2);
    [UIView animateWithDuration:.3 animations:^{
        self.alpha = 0;
        self.center = offscreen;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if(completion) completion(finished);
    }];
}

-(void) animateOnScreenFrom:(CGPoint)offscreen withCompletion:(void (^)(BOOL finished))completion{
    CGPoint onscreen = self.center;
    self.center = offscreen;

    [UIView animateKeyframesWithDuration:.7 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:.25 animations:^{
            self.alpha = 1;
            self.center = CGPointMake(onscreen.x, onscreen.y+12);
        }];
        [UIView addKeyframeWithRelativeStartTime:.25 relativeDuration:.25 animations:^{
            self.center = onscreen;
        }];
        [UIView addKeyframeWithRelativeStartTime:.5 relativeDuration:.25 animations:^{
            self.center = CGPointMake(onscreen.x, onscreen.y+8);
        }];
        [UIView addKeyframeWithRelativeStartTime:.75 relativeDuration:.25 animations:^{
            self.center = onscreen;
        }];
    } completion:^(BOOL finished){
        if(completion) completion(finished);
    }];
}

-(void) animateBounceToTopOfScreenAtX:(CGFloat)xLoc
                         withDuration:(CGFloat)duration
                   withTargetRotation:(CGFloat)targetRotation
                           completion:(void (^)(BOOL finished))completion{
    
    CGFloat targetSize = 80;
    
    CGFloat rotStart = self.rotation;
    CGFloat rotDiff = targetRotation - rotStart;
    
    [UIView animateKeyframesWithDuration:duration delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{

        
//        NSMutableArray* keyTimes = [NSMutableArray arrayWithObjects:
//                                    [NSNumber numberWithFloat:0.0],
//                                    [NSNumber numberWithFloat:0.4],
//                                    [NSNumber numberWithFloat:0.7],
//                                    [NSNumber numberWithFloat:1.0], nil];
//        bounceAnimation.keyTimes = keyTimes;
//        bounceAnimation.values = [NSArray arrayWithObjects:
//                                  [NSValue valueWithCATransform3D:CATransform3DConcat(transform3d, CATransform3DMakeScale(1.0, 1.0, 1.0))],
//                                  [NSValue valueWithCATransform3D:CATransform3DConcat(transform3d, CATransform3DMakeScale(1.0+max, 1.0+max, 1.0))],
//                                  [NSValue valueWithCATransform3D:CATransform3DConcat(transform3d, CATransform3DMakeScale(1.0+min, 1.0+min, 1.0))],
//                                  [NSValue valueWithCATransform3D:CATransform3DConcat(transform3d, CATransform3DMakeScale(1.0, 1.0, 1.0))],
        //
        // total bounce duration: .3 of the .8s of the total animation: so .375 of keyframe
        //
        // dur1: .4 * .375 = 0.15
        // dur2: .3 * .375 = 0.1125
        // dur3: .3 * .375 = 0.1125

        // button bounce
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:.15 animations:^{
            // rotate to .4 * diff
            // scale to 1.4
            CGFloat stepRot = rotStart + rotDiff * 0.4;
            self.transform = CGAffineTransformConcat(CGAffineTransformMakeRotation(stepRot), CGAffineTransformMakeScale(1.4, 1.4));
        }];
        [UIView addKeyframeWithRelativeStartTime:.15 relativeDuration:.1125 animations:^{
            // rotate to .7 * diff
            // scale to .8
            CGFloat stepRot = rotStart + rotDiff * 0.7;
            self.transform = CGAffineTransformConcat(CGAffineTransformMakeRotation(stepRot), CGAffineTransformMakeScale(0.8, 0.8));
        }];
        [UIView addKeyframeWithRelativeStartTime:0.2625 relativeDuration:.1125 animations:^{
            // scale to 1
            // rotate to target
            self.transform = CGAffineTransformConcat(CGAffineTransformMakeRotation(targetRotation), CGAffineTransformMakeScale(1.0, 1.0));
        }];
        
        CGPoint originalCenter = self.center;
        CGPoint targetCenter = CGPointMake(xLoc + targetSize/2, targetSize/2);
        
        int firstDrop = 14;
        int topOfBounce = 18;
        int maxSteps = 20;
        CGFloat bounceHeight = 25;
        
        for (int foo = 1; foo <= maxSteps; foo += 1) {
            [UIView addKeyframeWithRelativeStartTime:((foo-1)/(float)maxSteps) relativeDuration:1/(float)maxSteps animations:^{
                CGFloat x;
                CGFloat y;
                CGFloat t;
                if(foo <= firstDrop){
                    t = foo/(float)firstDrop;
                    x = logTransform(originalCenter.x, targetCenter.x, t);
                    y = sqTransform(originalCenter.y, targetCenter.y, t);
                }else if(foo <= topOfBounce){
                    // 7, 8
                    t = (foo-firstDrop)/(float)(topOfBounce - firstDrop);
                    x = targetCenter.x;
                    y = sqrtTransform(targetCenter.y, targetCenter.y + bounceHeight, t);
                }else{
                    // 9
                    t = (foo-topOfBounce) / (float)(maxSteps - topOfBounce);
                    x = targetCenter.x;
                    y = sqTransform(targetCenter.y + bounceHeight, targetCenter.y, t);
                }
                self.bounds = CGRectMake(0, 0, targetSize, targetSize);
                self.center = CGPointMake(x, y);
            }];
        }
        
    } completion:^(BOOL finished) {
        if(completion) completion(finished);
    }];
}

-(void) animateToPercent:(CGFloat)progress success:(BOOL)succeeded completion:(void (^)(BOOL targetSuccess))completion{
    targetProgress = progress;
    targetSuccess = succeeded;
    
    if(lastProgress < targetProgress){
        lastProgress += (targetProgress / 10.0);
        if(lastProgress > targetProgress){
            lastProgress = targetProgress;
        }
    }
    
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    
    CGFloat radius = self.drawableFrame.size.width / 2 - 1;
    CAShapeLayer *circle;
    if([self.layer.sublayers count]){
        circle = [self.layer.sublayers firstObject];
    }else{
        circle=[CAShapeLayer layer];
        circle.fillColor=[UIColor clearColor].CGColor;
        circle.strokeColor=[[UIColor whiteColor] colorWithAlphaComponent:.7].CGColor;
        CAShapeLayer *mask=[CAShapeLayer layer];
        circle.mask = mask;
        [self.layer addSublayer:circle];
    }
    if(radius != lastRadius){
        lastRadius = radius;
        circle.path=[UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:2*M_PI*0-M_PI_2 endAngle:2*M_PI*1-M_PI_2 clockwise:YES].CGPath;
        circle.lineWidth=radius*2;
        ((CAShapeLayer*)circle.mask).path=[UIBezierPath bezierPathWithArcCenter:center radius:radius-2 startAngle:2*M_PI*0-M_PI_2 endAngle:2*M_PI*1-M_PI_2 clockwise:YES].CGPath;
    }
    
    circle.strokeEnd = lastProgress;
    
    if(lastProgress >= 1.0){
        CAShapeLayer *mask2=[CAShapeLayer layer];
        mask2.path=[UIBezierPath bezierPathWithArcCenter:center radius:radius-2 startAngle:2*M_PI*0-M_PI_2 endAngle:2*M_PI*1-M_PI_2 clockwise:YES].CGPath;
        
        UIView* checkOrXView = [[UIView alloc] initWithFrame:self.bounds];
        checkOrXView.backgroundColor = [UIColor whiteColor];
        checkOrXView.layer.mask = mask2;
        
        [[NSThread mainThread] performBlock:^{
            CAShapeLayer* checkMarkOrXLayer = [CAShapeLayer layer];
            checkMarkOrXLayer.anchorPoint = CGPointZero;
            checkMarkOrXLayer.bounds = self.bounds;
            UIBezierPath* path = [UIBezierPath bezierPath];
            if(succeeded){
                CGPoint start = CGPointMake(30, 41);
                CGPoint corner = CGPointMake(start.x + 6, start.y + 6);
                CGPoint end = CGPointMake(corner.x + 14, corner.y - 14);
                [path moveToPoint:start];
                [path addLineToPoint:corner];
                [path addLineToPoint:end];
            }else{
                CGFloat size = 14;
                CGPoint start = CGPointMake(33, 33);
                CGPoint end = CGPointMake(start.x + size, start.y + size);
                [path moveToPoint:start];
                [path addLineToPoint:end];
                start = CGPointMake(start.x + size, start.y);
                end = CGPointMake(start.x - size, start.y + size);
                [path moveToPoint:start];
                [path addLineToPoint:end];
            }
            checkMarkOrXLayer.path = path.CGPath;
            checkMarkOrXLayer.strokeColor = [UIColor blackColor].CGColor;
            checkMarkOrXLayer.lineWidth = 6;
            checkMarkOrXLayer.lineCap = @"square";
            checkMarkOrXLayer.strokeStart = 0;
            checkMarkOrXLayer.strokeEnd = 1;
            checkMarkOrXLayer.backgroundColor = [UIColor clearColor].CGColor;
            checkMarkOrXLayer.fillColor = [UIColor clearColor].CGColor;
            
            checkOrXView.alpha = 0;
            [checkOrXView.layer addSublayer:checkMarkOrXLayer];
            [self addSubview:checkOrXView];
            [UIView animateWithDuration:.3 animations:^{
                checkOrXView.alpha = 1;
            } completion:^(BOOL finished){
                if(completion) completion(targetSuccess);
            }];
        } afterDelay:.3];
    }else{
        [[NSThread mainThread] performBlock:^{
            [self animateToPercent:targetProgress success:targetSuccess completion:completion];
        } afterDelay:.03];
    }
}


@end
