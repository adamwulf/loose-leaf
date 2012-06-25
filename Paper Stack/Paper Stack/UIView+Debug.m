//
//  UIView+Debug.m
//  scratchpaper
//
//  Created by Adam Wulf on 6/25/12.
//
//

#import "UIView+Debug.h"

@implementation UIView (Debug)

-(void) showDebugBorder{
    self.layer.borderColor = [UIColor redColor].CGColor;
    self.layer.borderWidth = 1;
}


@end
