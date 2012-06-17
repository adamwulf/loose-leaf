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

@end
