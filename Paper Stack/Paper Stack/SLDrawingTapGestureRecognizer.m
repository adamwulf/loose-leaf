//
//  SLDrawingTapGestureRecognizer.m
//  PaintingSample
//
//  Created by Adam Wulf on 11/1/12.
//
//

#import "SLDrawingTapGestureRecognizer.h"

@implementation SLDrawingTapGestureRecognizer

@synthesize fingerWidth;

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGFloat newFingerWidth = [[touch valueForKey:@"pathMajorRadius"] floatValue];
    if(newFingerWidth < 2) newFingerWidth = 2;
    if(abs(newFingerWidth - fingerWidth) > 1){
        if(newFingerWidth > fingerWidth) fingerWidth += 1;
        if(newFingerWidth < fingerWidth) fingerWidth -= 1;
    }
    fingerWidth = newFingerWidth;
    [super touchesBegan:touches withEvent:event];
}



@end
