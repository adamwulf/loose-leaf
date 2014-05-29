//
//  MMMemoryProfileView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 5/29/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMMemoryProfileView.h"
#import "MMBackgroundTimer.h"

@implementation MMMemoryProfileView{
    NSTimer* profileTimer;
    NSOperationQueue* timerQueue;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        
        timerQueue = [[NSOperationQueue alloc] init];
        
        MMBackgroundTimer* backgroundTimer = [[MMBackgroundTimer alloc] initWithInterval:1 andTarget:self andSelector:@selector(timerDidFire)];
        [timerQueue addOperation:backgroundTimer];
        
    }
    return self;
}


-(void) timerDidFire{
    NSLog(@"main thread? %i", [NSThread isMainThread]);
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
