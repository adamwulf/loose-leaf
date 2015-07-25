//
//  MMUntouchableTutorialView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 6/9/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMUntouchableTutorialView.h"
#import "Constants.h"

@implementation MMUntouchableTutorialView

-(BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    CGFloat buttonBuffer = kWidthOfSidebarButton + 2 * kWidthOfSidebarButtonBuffer;

    if(point.x < buttonBuffer){
        return NO;
    }else if(point.y < buttonBuffer){
        return NO;
    }else if(point.x > self.bounds.size.width - buttonBuffer){
        return NO;
    }else if(point.y > self.bounds.size.height - buttonBuffer){
        return NO;
    }
    return YES;
}


@end
