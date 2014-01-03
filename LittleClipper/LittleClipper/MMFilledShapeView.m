//
//  MMShapeFillerView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 12/16/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMFilledShapeView.h"
#import "UIColor+ColorWithHex.h"

@implementation MMFilledShapeView{
    NSMutableArray* pathsToFill;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        pathsToFill = [NSMutableArray array];
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
    }
    return self;
}

-(void) clear{
    [pathsToFill removeAllObjects];
    [self setNeedsDisplay];
}

-(void) addShapePath:(UIBezierPath*)path{
    [pathsToFill addObject:path];
    [self setNeedsDisplay];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
	CGContextFillRect(context, self.bounds);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    
    
    for (UIBezierPath* path in pathsToFill) {
        UIColor* color;
        CGFloat red, blue, green;
        do{
            color = [[UIColor randomColor] colorWithAlphaComponent:.5];
            [color getRed:&red green:&green blue:&blue alpha:nil];
        }while(red > .7 || green > .7 || blue > .7);
        [color setFill];
        [path fill];
    }
}


-(BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    return NO;
}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    return nil;
}

@end
