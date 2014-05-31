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
#import <mach/mach.h>

@implementation MMMemoryProfileView{
    NSTimer* profileTimer;
    NSOperationQueue* timerQueue;
}

@synthesize stackView;

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
        
        self.contentScaleFactor = 1;
        
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
    [[UIBezierPath bezierPathWithRect:self.bounds] fill];
    [[UIColor blackColor] setFill];
    
    // Drawing code
    int numberInImageCache = (int) [[MMLoadImageCache sharedInstance] numberOfItemsHeldInCache];
    int numberOfLoadedPagePreviews = (int) [[MMPageCacheManager sharedInstance] numberOfPagesWithLoadedPreviewImage];
    int numberOfLoadedPageStates = (int) [[MMPageCacheManager sharedInstance] numberOfStateLoadedPages];
    int numberOfItemsInTrash = (int) [[JotTrashManager sharedInstance] numberOfItemsInTrash];
    
    
    CGFloat y = 50;

    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    if(kerr != KERN_SUCCESS){
        size = 0;
    }
    [@"Entire App:" drawAtPoint:CGPointMake(150, (y += 40)) withFont:font];
    NSString* virtualBytes = [NSByteCountFormatter stringFromByteCount:info.virtual_size countStyle:NSByteCountFormatterCountStyleBinary];
    [[NSString stringWithFormat:@"virtual memory: %@", virtualBytes] drawAtPoint:CGPointMake(160, (y += 20)) withFont:font];
    NSString* residentBytes = [NSByteCountFormatter stringFromByteCount:info.resident_size countStyle:NSByteCountFormatterCountStyleBinary];
    [[NSString stringWithFormat:@"resident memory: %@", residentBytes] drawAtPoint:CGPointMake(160, (y += 20)) withFont:font];
    
    [@"MMLoadImageCache:" drawAtPoint:CGPointMake(150, y += 40) withFont:font];
    [[NSString stringWithFormat:@"# of Images: %d", numberInImageCache] drawAtPoint:CGPointMake(160, (y += 20)) withFont:font];
    NSString* bytesInImages = [NSByteCountFormatter stringFromByteCount:[[MMLoadImageCache sharedInstance] memoryOfLoadedImages] countStyle:NSByteCountFormatterCountStyleBinary];
    [[NSString stringWithFormat:@"memory in images: %@", bytesInImages] drawAtPoint:CGPointMake(160, (y += 20)) withFont:font];

    [@"MMPageCacheManager:" drawAtPoint:CGPointMake(150, (y += 40)) withFont:font];
    [[NSString stringWithFormat:@"# in page previews: %d", numberOfLoadedPagePreviews] drawAtPoint:CGPointMake(160, (y += 20)) withFont:font];
    [[NSString stringWithFormat:@"# in page states: %d", numberOfLoadedPageStates] drawAtPoint:CGPointMake(160, (y += 20)) withFont:font];
    NSString* bytesInPages = [NSByteCountFormatter stringFromByteCount:[[MMPageCacheManager sharedInstance] memoryOfStateLoadedPages] countStyle:NSByteCountFormatterCountStyleBinary];
    [[NSString stringWithFormat:@"memory in states: %@", bytesInPages] drawAtPoint:CGPointMake(160, (y += 20)) withFont:font];
    
    if(stackView){
        [@"Paper Stack:" drawAtPoint:CGPointMake(150, (y += 40)) withFont:font];
        NSString* bytesInView = [NSByteCountFormatter stringFromByteCount:stackView.fullByteSize countStyle:NSByteCountFormatterCountStyleBinary];
        [[NSString stringWithFormat:@"memory: %@", bytesInView] drawAtPoint:CGPointMake(160, (y += 20)) withFont:font];
    }

    [@"JotTrashManager:" drawAtPoint:CGPointMake(150, (y += 40)) withFont:font];
    [[NSString stringWithFormat:@"# items in trash: %d", numberOfItemsInTrash] drawAtPoint:CGPointMake(160, (y += 20)) withFont:font];
    NSString* bytesInTrash = [NSByteCountFormatter stringFromByteCount:[[JotTrashManager sharedInstance] knownBytesInTrash] countStyle:NSByteCountFormatterCountStyleBinary];
    [[NSString stringWithFormat:@"memory: %@", bytesInTrash] drawAtPoint:CGPointMake(160, (y += 20)) withFont:font];
    

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

    [@"JotGLTexture:" drawAtPoint:CGPointMake(150, (y += 40)) withFont:font];
    NSString* bytesForTextures = [NSByteCountFormatter stringFromByteCount:[JotGLTexture totalTextureBytes] countStyle:NSByteCountFormatterCountStyleBinary];
    [[NSString stringWithFormat:@"textures: %@", bytesForTextures] drawAtPoint:CGPointMake(160, (y += 20)) withFont:font];
}

@end
