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
    visibleStack = [[NSMutableArray array] retain]; // use NSMutableArray stack additions
    hiddenStack = [[NSMutableArray array] retain]; // use NSMutableArray stack additions
    stackHolder = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:stackHolder];
    paperIcon = [[SLPaperIcon alloc] initWithFrame:CGRectMake(400, 100, 100, 100)];
    [self addSubview:paperIcon];
}




/**
 * adds the page to the bottom of the stack
 * and adds to the bottom of the subviews
 */
-(void) addPaperToBottomOfStack:(SLPaperView*)page{
    page.delegate = self;
    if([visibleStack count]){
        [stackHolder insertSubview:page belowSubview:[visibleStack peek]];
    }else{
        [stackHolder addSubview:page];
    }
    [visibleStack addToBottomOfStack:page];
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
    return [visibleStack peek] == page;
}

-(CGRect) isPanningAndScalingPage:(SLPaperView*)page fromFrame:(CGRect)fromFrame toFrame:(CGRect)toFrame{
    if(page == [visibleStack peek]){
        
    }
    return toFrame;
}

-(void) finishedPanningAndScalingPage:(SLPaperView*)page fromFrame:(CGRect)fromFrame toFrame:(CGRect)toFrame{
    if(page.scale <= 1){
        // bounce it back to full screen
        //
        // 
        [UIView animateWithDuration:.15 delay:0 options:UIViewAnimationOptionAllowUserInteraction
                         animations:^(void){
                             page.scale = 1;
                             CGRect bounceFrame = self.bounds;
                             bounceFrame.origin.x = bounceFrame.origin.x-10;
                             bounceFrame.origin.y = bounceFrame.origin.y-10;
                             bounceFrame.size.width = bounceFrame.size.width+10*2;
                             bounceFrame.size.height = bounceFrame.size.height+10*2;
                             page.frame = bounceFrame;
                         } completion:^(BOOL finished){
                             if(finished){
                                 [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionAllowUserInteraction
                                                  animations:^(void){
                                                      page.frame = self.bounds;
                                                      page.scale = 1;
                                                  } completion:nil];
                             }
                         }];
    }else{
        CGFloat newX = toFrame.origin.x;
        CGFloat newY = toFrame.origin.y;
        if(newX > 0) newX = 0;
        if(newY > 0) newY = 0;
        if(newX + toFrame.size.width < self.frame.size.width){
            newX = self.frame.size.width - toFrame.size.width;
        }
        if(newY + toFrame.size.height < self.frame.size.height){
            newY = self.frame.size.height - toFrame.size.height;
        }
        if(newX != toFrame.origin.x || newY != toFrame.origin.y){
            toFrame.origin.x = newX;
            toFrame.origin.y = newY;
            [UIView animateWithDuration:0.15 animations:^(void){
                page.frame = toFrame;
            }];
        }
    }
}


@end
