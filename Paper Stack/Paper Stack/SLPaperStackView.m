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
    return toFrame;
}

-(void) finishedPanningAndScalingPage:(SLPaperView*)page fromFrame:(CGRect)fromFrame toFrame:(CGRect)toFrame{
    if(page.scale < 1){
        // bounce it back to full screen
        [UIView animateWithDuration:0.3 animations:^(void){
            page.frame = self.bounds;
            page.scale = 1;
        }];
    }
}


@end
