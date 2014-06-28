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
}

@synthesize memoryManager;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        
        self.contentScaleFactor = 1;
        
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerDidFire) userInfo:nil repeats:YES];
    }
    return self;
}


-(void) timerDidFire{
//    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    UIFont* font = [UIFont systemFontOfSize:20];
    
    [[[UIColor whiteColor] colorWithAlphaComponent:.5] setFill];
    [[UIBezierPath bezierPathWithRect:self.bounds] fill];
    [[UIColor blackColor] setFill];
    
    CGFloat y = 50;

    NSDictionary* attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    [@"Entire App:" drawAtPoint:CGPointMake(150, (y += 40)) withAttributes:attributes];
    NSString* virtualBytes = [NSByteCountFormatter stringFromByteCount:memoryManager.virtualSize countStyle:NSByteCountFormatterCountStyleBinary];
    NSString* maxVirtualBytes = [NSByteCountFormatter stringFromByteCount:memoryManager.maxVirtualSize countStyle:NSByteCountFormatterCountStyleBinary];
    [[NSString stringWithFormat:@"virtual memory: %@", virtualBytes] drawAtPoint:CGPointMake(160, (y += 20)) withAttributes:attributes];
    [[NSString stringWithFormat:@"[%@]", maxVirtualBytes] drawAtPoint:CGPointMake(460, y) withAttributes:attributes];
    NSString* residentBytes = [NSByteCountFormatter stringFromByteCount:memoryManager.residentSize countStyle:NSByteCountFormatterCountStyleBinary];
    NSString* maxResidentBytes = [NSByteCountFormatter stringFromByteCount:memoryManager.maxResidentSize countStyle:NSByteCountFormatterCountStyleBinary];
    [[NSString stringWithFormat:@"resident memory: %@", residentBytes] drawAtPoint:CGPointMake(160, (y += 20)) withAttributes:attributes];
    [[NSString stringWithFormat:@"[%@]", maxResidentBytes] drawAtPoint:CGPointMake(460, y) withAttributes:attributes];
    NSString* accountedMemory = [NSByteCountFormatter stringFromByteCount:memoryManager.accountedResidentBytes countStyle:NSByteCountFormatterCountStyleBinary];
    NSString* maxAccountedMemory = [NSByteCountFormatter stringFromByteCount:memoryManager.maxAccountedResidentBytes countStyle:NSByteCountFormatterCountStyleBinary];
    [[NSString stringWithFormat:@"accounted memory: %@", accountedMemory] drawAtPoint:CGPointMake(160, (y += 20)) withAttributes:attributes];
    [[NSString stringWithFormat:@"[%@]", maxAccountedMemory] drawAtPoint:CGPointMake(460, y) withAttributes:attributes];
    NSString* unaccountedMemory = [NSByteCountFormatter stringFromByteCount:memoryManager.unaccountedResidentBytes countStyle:NSByteCountFormatterCountStyleBinary];
    NSString* maxUnaccountedMemory = [NSByteCountFormatter stringFromByteCount:memoryManager.maxUnaccountedResidentBytes countStyle:NSByteCountFormatterCountStyleBinary];
    [[NSString stringWithFormat:@"unaccounted memory: %@", unaccountedMemory] drawAtPoint:CGPointMake(160, (y += 20)) withAttributes:attributes];
    [[NSString stringWithFormat:@"[%@]", maxUnaccountedMemory] drawAtPoint:CGPointMake(460, y) withAttributes:attributes];
    
    [@"MMPageCacheManager:" drawAtPoint:CGPointMake(150, (y += 40)) withAttributes:attributes];
    [[NSString stringWithFormat:@"# in page previews: %d", memoryManager.numberOfLoadedPagePreviews] drawAtPoint:CGPointMake(160, (y += 20)) withAttributes:attributes];
    [[NSString stringWithFormat:@"# in page states: %d", memoryManager.numberOfLoadedPageStates] drawAtPoint:CGPointMake(160, (y += 20)) withAttributes:attributes];
    NSString* bytesInPages = [NSByteCountFormatter stringFromByteCount:memoryManager.residentPageStateMemory countStyle:NSByteCountFormatterCountStyleBinary];
    [[NSString stringWithFormat:@"memory in states: %@", bytesInPages] drawAtPoint:CGPointMake(160, (y += 20)) withAttributes:attributes];
    
    [@"Paper Stack:" drawAtPoint:CGPointMake(150, (y += 40)) withAttributes:attributes];
    NSString* bytesInView = [NSByteCountFormatter stringFromByteCount:memoryManager.residentStackViewMemory countStyle:NSByteCountFormatterCountStyleBinary];
    [[NSString stringWithFormat:@"memory: %@", bytesInView] drawAtPoint:CGPointMake(160, (y += 20)) withAttributes:attributes];

    [@"JotTrashManager:" drawAtPoint:CGPointMake(150, (y += 40)) withAttributes:attributes];
    [[NSString stringWithFormat:@"# items in trash: %d", memoryManager.numberOfItemsInTrash] drawAtPoint:CGPointMake(160, (y += 20)) withAttributes:attributes];
    NSString* bytesInTrash = [NSByteCountFormatter stringFromByteCount:memoryManager.residentTrashMemory countStyle:NSByteCountFormatterCountStyleBinary];
    [[NSString stringWithFormat:@"memory: %@", bytesInTrash] drawAtPoint:CGPointMake(160, (y += 20)) withAttributes:attributes];
    
    [@"MMLoadImageCache:" drawAtPoint:CGPointMake(150, y += 40) withAttributes:attributes];
    [[NSString stringWithFormat:@"# of Images: %d", memoryManager.numberInImageCache] drawAtPoint:CGPointMake(160, (y += 20)) withAttributes:attributes];
    NSString* bytesInImages = [NSByteCountFormatter stringFromByteCount:memoryManager.residentImageCacheMemory countStyle:NSByteCountFormatterCountStyleBinary];
    [[NSString stringWithFormat:@"memory in images: %@", bytesInImages] drawAtPoint:CGPointMake(160, (y += 20)) withAttributes:attributes];

    [@"------" drawAtPoint:CGPointMake(150, (y += 40)) withAttributes:attributes];
    
    [@"Scrap Backgrounds:" drawAtPoint:CGPointMake(150, (y += 40)) withAttributes:attributes];
    NSString* bytesInBackgrounds = [NSByteCountFormatter stringFromByteCount:memoryManager.totalBytesInScrapBackgrounds countStyle:NSByteCountFormatterCountStyleBinary];
    [[NSString stringWithFormat:@"memory: %@", bytesInBackgrounds] drawAtPoint:CGPointMake(160, (y += 20)) withAttributes:attributes];
    
    [@"JotBufferManager:" drawAtPoint:CGPointMake(150, (y += 40)) withAttributes:attributes];
    NSDictionary* cacheStats = [[JotBufferManager sharedInstace] cacheMemoryStats];
    NSArray* keys = [[cacheStats allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString* obj1, NSString* obj2) {
        return [obj1 compare:obj2 options:NSCaseInsensitiveSearch | NSNumericSearch];
    }];
    for(NSString* key in keys){
        int bytesForKey = [[cacheStats objectForKey:key] intValue];
        NSString* bytesInVBOsStr = [NSByteCountFormatter stringFromByteCount:bytesForKey countStyle:NSByteCountFormatterCountStyleBinary];
        [[NSString stringWithFormat:@"%@: %@", key, bytesInVBOsStr] drawAtPoint:CGPointMake(160, (y += 20)) withAttributes:attributes];
    }

    [@"JotGLTexture:" drawAtPoint:CGPointMake(150, (y += 40)) withAttributes:attributes];
    NSString* bytesForTextures = [NSByteCountFormatter stringFromByteCount:memoryManager.totalBytesInTextures countStyle:NSByteCountFormatterCountStyleBinary];
    [[NSString stringWithFormat:@"textures: %@", bytesForTextures] drawAtPoint:CGPointMake(160, (y += 20)) withAttributes:attributes];
}

@end
