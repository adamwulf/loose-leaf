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
#import <JotUI/JotUI.h>

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
        
//        MMBackgroundTimer* backgroundTimer = [[MMBackgroundTimer alloc] initWithInterval:1 andTarget:self andSelector:@selector(timerDidFire)];
//        [timerQueue addOperation:backgroundTimer];
        
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerDidFire) userInfo:nil repeats:YES];
        
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
    int numberInImageCache = (int) [[MMLoadImageCache sharedInstace] numberOfItemsHeldInCache];
    int numberOfLoadedPagePreviews = (int) [[MMPageCacheManager sharedInstace] numberOfPagesWithLoadedPreviewImage];
    int numberOfLoadedPageStates = (int) [[MMPageCacheManager sharedInstace] numberOfStateLoadedPages];
    int numberOfItemsInTrash = (int) [[JotTrashManager sharedInstace] numberOfItemsInTrash];
    
    CGFloat y = 50;
    [@"MMLoadImageCache:" drawAtPoint:CGPointMake(150, y) withFont:font];
    [[NSString stringWithFormat:@"# of Images: %d", numberInImageCache] drawAtPoint:CGPointMake(160, (y += 20)) withFont:font];

    [@"MMPageCacheManager:" drawAtPoint:CGPointMake(150, (y += 40)) withFont:font];
    [[NSString stringWithFormat:@"# in page previews: %d", numberOfLoadedPagePreviews] drawAtPoint:CGPointMake(160, (y += 20)) withFont:font];
    [[NSString stringWithFormat:@"# in page states: %d", numberOfLoadedPageStates] drawAtPoint:CGPointMake(160, (y += 20)) withFont:font];

    [@"JotTrashManager:" drawAtPoint:CGPointMake(150, (y += 40)) withFont:font];
    [[NSString stringWithFormat:@"# items in trash: %d", numberOfItemsInTrash] drawAtPoint:CGPointMake(160, (y += 20)) withFont:font];

    [@"JotBufferManager:" drawAtPoint:CGPointMake(150, (y += 40)) withFont:font];
    
    NSDictionary* cacheStats = [[JotBufferManager sharedInstace] cacheMemoryStats];
    NSArray* keys = [[cacheStats allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString* obj1, NSString* obj2) {
        return [obj1 compare:obj2 options:NSCaseInsensitiveSearch | NSNumericSearch];
    }];
    for(NSString* key in keys){
        int bytesForKey = [[cacheStats objectForKey:key] intValue];
        NSString* bytesInVBOsStr = [NSByteCountFormatter stringFromByteCount:bytesForKey countStyle:NSByteCountFormatterCountStyleBinary];
        [[NSString stringWithFormat:@"%@: %@", key, bytesInVBOsStr] drawAtPoint:CGPointMake(160, (y += 20)) withFont:font];
    }
}

@end
