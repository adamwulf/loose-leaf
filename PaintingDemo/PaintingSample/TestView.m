//
//  TestView.m
//  PaintingSample
//
//  Created by Adam Wulf on 10/5/12.
//
//

#import "TestView.h"

@implementation TestView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [[UIColor whiteColor] set];
    [[UIBezierPath bezierPathWithRect:[self bounds]] fill];
    

    // Drawing code
    UIBezierPath* path1 = [UIBezierPath bezierPathWithRect:CGRectMake(50, 50, 100, 100)];
    UIBezierPath* path2 = [UIBezierPath bezierPathWithRect:CGRectMake(130, 100, 40, 40)];
    UIBezierPath* path3 = [path1 pathFromUnionWithPath:path2];
    UIBezierPath* path4 = [path1 pathFromDifferenceWithPath:path2];
    UIBezierPath* path5 = [path1 pathFromExclusiveOrWithPath:path2];
    UIBezierPath* path6 = [path1 pathFromIntersectionWithPath:path2];
    
    
    [path3 applyTransform:CGAffineTransformMakeTranslation(0, 120)];
    [path4 applyTransform:CGAffineTransformMakeTranslation(0, 240)];
    [path5 applyTransform:CGAffineTransformMakeTranslation(0, 360)];
    [path6 applyTransform:CGAffineTransformMakeTranslation(0, 480)];

    [[UIColor redColor] setStroke];
    [[[UIColor redColor] colorWithAlphaComponent:.5] setFill];
    CGContextSetLineCap(context, kCGLineCapRound);
    path3.lineWidth = 4;
    [path3 stroke];
    [path3 fill];
    path4.lineWidth = 4;
    [path4 stroke];
    [path4 fill];
    path5.lineWidth = 4;
    [path5 stroke];
    [path5 fill];
    path6.lineWidth = 4;
    [path6 stroke];
    [path6 fill];
    
    [[UIColor greenColor] set];
    path2.lineWidth = 4;
    [path2 stroke];
    [[UIColor blueColor] set];
    path1.lineWidth = 4;
    [path1 stroke];
    
}


@end
