//
//  SLPaperStackView.m
//  Paper Stack
//
//  Created by Adam Wulf on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SLPaperStackView.h"

@implementation SLPaperStackView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self awakeFromNib];
    }
    return self;
}

-(void) awakeFromNib{
    visibleStack = [[NSMutableArray array] retain];
    hiddenStack = [[NSMutableArray array] retain];
    
}




/**
 * adds the page to the bottom of the stack
 * and adds to the bottom of the subviews
 */
-(void) addPaperToBottomOfStack:(SLPaperView*)page{
    page.delegate = self;
    if([visibleStack count]){
        [self insertSubview:page belowSubview:[visibleStack lastObject]];
    }else{
        [self addSubview:page];
    }
    [visibleStack addObject:page];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/




#pragma mark - SLPaperViewDelegate

-(BOOL) allowsScaleForPage:(SLPaperView*)page{
    return [visibleStack objectAtIndex:0] == page;
}

-(CGRect) isPanningAndScalingPage:(SLPaperView*)page fromFrame:(CGRect)fromFrame toFrame:(CGRect)toFrame{
    if(page.scale < 1.0){
        if(toFrame.origin.y < 0) toFrame.origin.y = 0;
        if(toFrame.origin.y + toFrame.size.height > self.frame.size.height){
            toFrame.origin.y = self.frame.size.height - toFrame.size.height;
        }
    }
    if(page.scale >= 1.0){
        if(toFrame.origin.y > 0) toFrame.origin.y = 0;
        if(toFrame.origin.y + toFrame.size.height < self.frame.size.height){
            toFrame.origin.y = self.frame.size.height - toFrame.size.height;
        }
    }
    return toFrame;
}

-(void) finishedPanningAndScalingPage:(SLPaperView*)page fromFrame:(CGRect)fromFrame toFrame:(CGRect)toFrame{
    if(page.scale < 1){
        // bounce it back to full screen
        [UIView animateWithDuration:0.15 animations:^(void){
            CGRect bounceFrame = self.bounds;
            bounceFrame.origin.x = bounceFrame.origin.x-10;
            bounceFrame.origin.y = bounceFrame.origin.y-10;
            bounceFrame.size.width = bounceFrame.size.width+10*2;
            bounceFrame.size.height = bounceFrame.size.height+10*2;
            page.frame = bounceFrame;
        } completion:^(BOOL finished){
            [UIView animateWithDuration:0.15 animations:^(void){
                page.frame = self.bounds;
                page.scale = 1;
            }];
        }];
    }
}


@end
