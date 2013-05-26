//
//  Pen.h
//  jotuiexample
//
//  Created by Adam Wulf on 12/18/12.
//  Copyright (c) 2012 Adonit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JotUI/JotUI.h>

#define           VELOCITY_CLAMP_MIN 20
#define           VELOCITY_CLAMP_MAX 5000

@interface Pen : NSObject<JotViewDelegate>{

    CGFloat defaultMinSize;
    CGFloat defaultMaxSize;

    CGFloat minSize;
    CGFloat maxSize;
    CGFloat minAlpha;
    CGFloat maxAlpha;
    
    int numberOfTouches;
    CGFloat velocity;
    CGPoint lastLoc;
    NSDate* lastDate;
    
    BOOL shouldUseVelocity;
    
    UIColor* color;
}

@property (nonatomic, assign) CGFloat minSize;
@property (nonatomic, assign) CGFloat maxSize;
@property (nonatomic, assign) CGFloat minAlpha;
@property (nonatomic, assign) CGFloat maxAlpha;
@property (nonatomic) __strong UIColor* color;
@property (nonatomic, readonly) UIImage* texture;
/**
 * the velocity of the last touch, between 0 and 1
 *
 * a value of 0 means the pen is moving less than or equal to
 * the VELOCITY_CLAMP_MIN
 * a value of 1 means the pen is moving faster than or equal to
 * the VELOCITY_CLAMP_MAX
 **/
@property (nonatomic, readonly) CGFloat velocity;

@property (nonatomic) BOOL shouldUseVelocity;

-(id) initWithMinSize:(CGFloat)_minSize andMaxSize:(CGFloat)_maxSize andMinAlpha:(CGFloat)_minAlpha andMaxAlpha:(CGFloat)_maxAlpha;

@end
