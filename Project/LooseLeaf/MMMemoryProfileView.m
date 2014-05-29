//
//  MMMemoryProfileView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 5/29/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMMemoryProfileView.h"
#import "MMBackgroundTimer.h"
#import "MMLoadImageCache.h"
#import "MMPageCacheManager.h"

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
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    UIFont* font = [UIFont systemFontOfSize:20];
    
    [[[UIColor whiteColor] colorWithAlphaComponent:.5] setFill];
    [[UIBezierPath bezierPathWithRect:CGRectMake(140, 40, 300, 150)] fill];
    [[UIColor blackColor] setFill];
    
    // Drawing code
    NSInteger numberInImageCache = [[MMLoadImageCache sharedInstace] numberOfItemsHeldInCache];
    NSInteger numberOfLoadedPagePreviews = [[MMPageCacheManager sharedInstace] numberOfPagesWithLoadedPreviewImage];
    NSInteger numberOfLoadedPageStates = [[MMPageCacheManager sharedInstace] numberOfStateLoadedPages];
    
    
    [@"MMLoadImageCache:" drawAtPoint:CGPointMake(150, 50) withFont:font];
    [[NSString stringWithFormat:@"# of Images: %d", numberInImageCache] drawAtPoint:CGPointMake(150, 70) withFont:font];

    [@"MMPageCacheManager:" drawAtPoint:CGPointMake(150, 110) withFont:font];
    [[NSString stringWithFormat:@"# in page previews: %d", numberOfLoadedPagePreviews] drawAtPoint:CGPointMake(150, 130) withFont:font];
    [[NSString stringWithFormat:@"# in page states: %d", numberOfLoadedPageStates] drawAtPoint:CGPointMake(150, 150) withFont:font];
}

@end
