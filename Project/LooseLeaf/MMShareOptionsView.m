//
//  MMShareOptionsView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/22/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMShareOptionsView.h"

@implementation MMShareOptionsView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.userInteractionEnabled = YES;
        
        CGFloat width = frame.size.width;
        CGRect lineRect = CGRectMake(width*0.1, 0, width*0.8, 1);
        UIView* line = [[UIView alloc] initWithFrame:lineRect];
        line.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        line.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.5];
        [self addSubview:line];
    }
    return self;
}

-(BOOL) shouldCloseWhenSidebarHides{
    return NO;
}

-(void) reset{
    self.alpha = 0;
}

-(void) hide{
    if(self.alpha){
        CGRect origFrame = self.frame;
        CGRect offsetFrame = origFrame;
        offsetFrame.origin.y += 10;
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.alpha = 0;
            self.frame = offsetFrame;
        }completion:^(BOOL finished){
            if(finished){
                self.frame = origFrame;
            }
        }];
    }
}

-(void) show{
    if(!self.alpha){
        CGRect origFrame = self.frame;
        CGRect offsetFrame = origFrame;
        offsetFrame.origin.y += 10;
        self.frame = offsetFrame;
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.alpha = 1;
            self.frame = origFrame;
        }completion:nil];
    }
}

-(void) updateInterfaceTo:(UIInterfaceOrientation)orientation{
    // noop
}


@end
