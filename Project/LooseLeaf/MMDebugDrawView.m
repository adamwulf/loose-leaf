//
//  MMDebugDrawView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/7/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMDebugDrawView.h"
#import "UIColor+ColorWithHex.h"

@implementation MMDebugDrawView{
    NSMutableArray* curves;
    NSMutableArray* colors;
}

static MMDebugDrawView* _instance = nil;

-(id) initWithFrame:(CGRect)frame{
    if(_instance) return _instance;
    if((self = [super initWithFrame:frame])){
        _instance = self;
        curves = [NSMutableArray array];
        colors = [NSMutableArray array];
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    return _instance;
}

+(MMDebugDrawView*) sharedInstace{
    if(!_instance){
        _instance = [[MMDebugDrawView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    }
    return _instance;
}

#pragma mark - Draw

-(void) clear{
    [curves removeAllObjects];
    [self setNeedsDisplay];
}

-(void) addCurve:(UIBezierPath*)path{
    [curves addObject:path];
    if([curves count] > [colors count]){
        [colors addObject:[UIColor randomColor]];
    }
    [self setNeedsDisplayInRect:path.bounds];
}

-(void) drawRect:(CGRect)rect{
    for(int i=0;i<[curves count];i++){
        UIBezierPath* path = [curves objectAtIndex:i];
        UIColor* color = [colors objectAtIndex:i];
        [color setStroke];
        path.lineWidth = 1;
        [path stroke];
    }
}

#pragma mark - Ignore Touches

/**
 * these two methods make sure that the ruler view
 * can never intercept any touch input. instead it will
 * effectively pass through this view to the views behind it
 */
-(UIView*) hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    return nil;
}

-(BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    return NO;
}

@end
