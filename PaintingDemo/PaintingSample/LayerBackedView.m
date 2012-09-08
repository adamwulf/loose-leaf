//
//  LayerBackedView.m
//  PaintingSample
//
//  Created by Adam Wulf on 9/7/12.
//
//

#import "LayerBackedView.h"
#import "PaintLayer.h"

@implementation LayerBackedView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = YES;
        paintLayer = [PaintLayer layer];
        paintLayer.contentsScale = [[UIScreen mainScreen] scale];
        [paintLayer setFrame:self.bounds];
        [self.layer addSublayer:paintLayer];
        
        self.clearsContextBeforeDrawing = NO;
        if([paintLayer respondsToSelector:@selector(setDrawsAsynchronously:)]){
            // iOS 6.0 only
            paintLayer.drawsAsynchronously = YES;
        }
        self.opaque = NO;
        paintLayer.opaque = NO;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void) setNeedsDisplay{
    [super setNeedsDisplay];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGFloat newFingerWidth = [[touch valueForKey:@"pathMajorRadius"] floatValue];
    if(newFingerWidth < 2) newFingerWidth = 2;
    if(abs(newFingerWidth - paintLayer.fingerWidth) > 1){
        if(newFingerWidth > paintLayer.fingerWidth) paintLayer.fingerWidth += 1;
        if(newFingerWidth < paintLayer.fingerWidth) paintLayer.fingerWidth -= 1;
    }
    paintLayer.fingerWidth = newFingerWidth;
    paintLayer.point0 = CGPointMake(-1, -1);
    paintLayer.point1 = CGPointMake(-1, -1); // previous previous point
    paintLayer.point2 = CGPointMake(-1, -1); // previous touch point
    paintLayer.point3 = [touch locationInView:self]; // current touch point
    paintLayer.lineEnded = NO;
    [paintLayer commitPointChanges];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGFloat newFingerWidth = [[touch valueForKey:@"pathMajorRadius"] floatValue];
    if(newFingerWidth < 2) newFingerWidth = 2;
    if(abs(newFingerWidth - paintLayer.fingerWidth) > 1){
        if(newFingerWidth > paintLayer.fingerWidth) paintLayer.fingerWidth += 1;
        if(newFingerWidth < paintLayer.fingerWidth) paintLayer.fingerWidth -= 1;
    }
    
    paintLayer.fingerWidth = newFingerWidth;
    paintLayer.point0 = paintLayer.point1;
    paintLayer.point1 = paintLayer.point2;
    paintLayer.point2 = paintLayer.point3;
    paintLayer.point3 = [touch locationInView:self];
    paintLayer.lineEnded = NO;
    [paintLayer commitPointChanges];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGFloat newFingerWidth = [[touch valueForKey:@"pathMajorRadius"] floatValue];
    if(newFingerWidth < 2) newFingerWidth = 2;
    if(abs(newFingerWidth - paintLayer.fingerWidth) > 1){
        if(newFingerWidth > paintLayer.fingerWidth) paintLayer.fingerWidth += 1;
        if(newFingerWidth < paintLayer.fingerWidth) paintLayer.fingerWidth -= 1;
    }else{
        paintLayer.fingerWidth = newFingerWidth;
    }
    paintLayer.point0 = paintLayer.point1;
    paintLayer.point1 = paintLayer.point2;
    paintLayer.point2 = paintLayer.point3;
    paintLayer.point3 = [touch locationInView:self];
    paintLayer.lineEnded = YES;
    [paintLayer commitPointChanges];
}
-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    //    UITouch *touch = [touches anyObject];
}

@end
