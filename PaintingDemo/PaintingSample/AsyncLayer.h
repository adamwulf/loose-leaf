//
//  AsyncLayer.h
//  PaintingSample
//
//  Created by Adam Wulf on 9/7/12.
//
//

#import <QuartzCore/QuartzCore.h>

@interface AsyncLayer : CALayer{
    CGContextRef cacheContext;
}

@property (nonatomic, assign) CGContextRef cacheContext;


@end
