//
//  PaintableImageView.m
//  PaintingSample
//
//  Created by Adam Wulf on 9/9/12.
//
//

#import "PaintableImageView.h"

@implementation PaintableImageView

- (id)initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
    if (self) {
        // Initialization code
        paint = [[PaintView alloc] initWithFrame:self.bounds];
        [self addSubview:paint];
    }
    return self;
}


#pragma mark - PaintTouchViewDelegate

-(void) drawArcAtStart:(CGPoint)point1 end:(CGPoint)point2 controlPoint1:(CGPoint)ctrl1 controlPoint2:(CGPoint)ctrl2 withFingerWidth:(CGFloat)fingerWidth{
    [paint drawArcAtStart:point1 end:point2 controlPoint1:ctrl1 controlPoint2:ctrl2 withFingerWidth:fingerWidth];
}

-(void) drawDotAtPoint:(CGPoint)point withFingerWidth:(CGFloat)fingerWidth{
    [paint drawDotAtPoint:point withFingerWidth:fingerWidth];
}

-(void) drawLineAtStart:(CGPoint)start end:(CGPoint)end withFingerWidth:(CGFloat)fingerWidth{
    [paint drawLineAtStart:start end:end withFingerWidth:fingerWidth];
}

@end
