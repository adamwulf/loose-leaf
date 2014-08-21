//
//  MMCloudKitButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/20/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCloudKitButton.h"

@implementation MMCloudKitButton

-(void) setFrame:(CGRect)frame{
    frame = CGRectInset(frame, -10, -10);
    [super setFrame:frame];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect frame = [self drawableFrame];
    
    CGContextSaveGState(context);
    if(self.isGreyscale){
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextFillRect(context, frame);
        [image drawInRect:frame blendMode:kCGBlendModeLuminosity alpha:1.0f];
    }else{
        [image drawInRect:frame];
    }
    CGContextRestoreGState(context);
}



@end
