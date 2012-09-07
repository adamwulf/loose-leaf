//
//  PaintLayer.h
//  PaintingSample
//
//  Created by Adam Wulf on 9/7/12.
//
//

#import <QuartzCore/QuartzCore.h>

@interface PaintLayer : CALayer{
    float hue;
    BOOL lineEnded;
    CGFloat fingerWidth;
    
    CGPoint point0;
    CGPoint point1;
    CGPoint point2;
    CGPoint point3;

}

@property (nonatomic, assign) float hue;
@property (nonatomic, assign) BOOL lineEnded;
@property (nonatomic, assign) CGFloat fingerWidth;

@property (nonatomic, assign) CGPoint point0;
@property (nonatomic, assign) CGPoint point1;
@property (nonatomic, assign) CGPoint point2;
@property (nonatomic, assign) CGPoint point3;


-(void) commitPointChanges;

@end
