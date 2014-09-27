//
//  MMMemoryManager.m
//  LooseLeaf
//
//  Created by Adam Wulf on 5/31/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMMemoryManager.h"
#import "MMBackgroundTimer.h"
#import "MMLoadImageCache.h"
#import "MMPageCacheManager.h"
#import "MMScrapPaperStackView.h"
#import "Constants.h"
#import <JotUI/JotUI.h>
#import <mach/mach.h>
#import "Mixpanel.h"

@implementation MMMemoryManager{
    NSOperationQueue* timerQueue;
    MMScrapPaperStackView* stackView;

    // accountedBytes is the sum of
    // memoryOfStateLoadedPages, stackViewFullByteSize,
    // knownBytesInTrash, and memoryOfLoadedImages
    int accountedResidentBytes;
    // memory by category
    int residentPageStateMemory;
    int residentStackViewMemory;
    int residentTrashMemory;
    int numberInImageCache;
    int residentImageCacheMemory;

    // additional stats
    int numberOfLoadedPagePreviews;
    int numberOfLoadedPageStates;
    int numberOfItemsInTrash;
    int virtualSize;
    int residentSize;
    int unaccountedResidentBytes;
    int totalBytesInScrapBackgrounds;
    int totalBytesInVBOs;
    int totalBytesInTextures;

    // track max during the session
    int maxVirtualSize;
    int maxResidentSize;
    int maxAccountedResidentBytes;
    int maxUnaccountedResidentBytes;
    int maxTotalBytesInScrapBackgrounds;
    int maxTotalBytesInVBOs;
    int maxTotalBytesInTextures;
}

@synthesize maxVirtualSize;
@synthesize maxResidentSize;
@synthesize maxAccountedResidentBytes;
@synthesize maxUnaccountedResidentBytes;
@synthesize maxTotalBytesInScrapBackgrounds;
@synthesize maxTotalBytesInTextures;
@synthesize maxTotalBytesInVBOs;
@synthesize virtualSize;
@synthesize residentSize;
@synthesize residentPageStateMemory;
@synthesize residentStackViewMemory;
@synthesize residentTrashMemory;
@synthesize residentImageCacheMemory;
@synthesize accountedResidentBytes;
@synthesize unaccountedResidentBytes;
@synthesize numberInImageCache;
@synthesize numberOfLoadedPagePreviews;
@synthesize numberOfLoadedPageStates;
@synthesize numberOfItemsInTrash;
@synthesize totalBytesInScrapBackgrounds;
@synthesize totalBytesInVBOs;
@synthesize totalBytesInTextures;

-(id) initWithStack:(MMScrapPaperStackView*)stack{
    if(self = [super init]){
        stackView = stack;
        timerQueue = [[NSOperationQueue alloc] init];
        MMBackgroundTimer* backgroundTimer = [[MMBackgroundTimer alloc] initWithInterval:1 andTarget:self andSelector:@selector(tick)];
        [self tick];
        [timerQueue addOperation:backgroundTimer];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(memoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

-(void) tick{
    // top level process information
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    if(kerr != KERN_SUCCESS){
        size = 0;
    }
    
    virtualSize = (int)info.virtual_size;
    residentSize = (int)info.resident_size;
    
    // bytes by logical ownership
    residentPageStateMemory = [[MMPageCacheManager sharedInstance] memoryOfStateLoadedPages];
    residentStackViewMemory = stackView.fullByteSize;
    residentTrashMemory = [[JotTrashManager sharedInstance] knownBytesInTrash];
    residentImageCacheMemory = [[MMLoadImageCache sharedInstance] memoryOfLoadedImages];
    accountedResidentBytes = residentPageStateMemory + residentStackViewMemory + residentTrashMemory + residentImageCacheMemory;
    unaccountedResidentBytes = residentSize - accountedResidentBytes;;
    
    // additional information
    numberInImageCache = (int) [[MMLoadImageCache sharedInstance] numberOfItemsHeldInCache];
    numberOfLoadedPagePreviews = (int) [[MMPageCacheManager sharedInstance] numberOfPagesWithLoadedPreviewImage];
    numberOfLoadedPageStates = (int) [[MMPageCacheManager sharedInstance] numberOfStateLoadedPages];
    numberOfItemsInTrash = (int) [[JotTrashManager sharedInstance] numberOfItemsInTrash];
    
    // bytes by object
    totalBytesInScrapBackgrounds = [MMScrapBackgroundView totalBackgroundBytes];
    totalBytesInVBOs = [[[[JotBufferManager sharedInstance] cacheMemoryStats] objectForKey:kVBOCacheSize] intValue];
    totalBytesInTextures = [JotGLTexture totalTextureBytes];
    
    if(virtualSize > maxVirtualSize){
        maxVirtualSize = virtualSize;
    }
    if(residentSize > maxResidentSize){
        maxResidentSize = residentSize;
    }
    if(accountedResidentBytes > maxAccountedResidentBytes){
        maxAccountedResidentBytes = accountedResidentBytes;
    }
    if(unaccountedResidentBytes > maxUnaccountedResidentBytes){
        maxUnaccountedResidentBytes = unaccountedResidentBytes;
    }
    if(totalBytesInScrapBackgrounds > maxTotalBytesInScrapBackgrounds){
        maxTotalBytesInScrapBackgrounds = totalBytesInScrapBackgrounds;
    }
    if(totalBytesInTextures > maxTotalBytesInTextures){
        maxTotalBytesInTextures = totalBytesInTextures;
    }
    if(totalBytesInVBOs > maxTotalBytesInVBOs){
        maxTotalBytesInVBOs = totalBytesInVBOs;
    }

    [[Mixpanel sharedInstance] registerSuperProperties:[NSDictionary dictionaryWithObjectsAndKeys:@(virtualSize), @"Virtual Size",
                                                        @(residentSize), @"Resident Size",
                                                        @(residentPageStateMemory), @"Resident Page State Memory",
                                                        @(residentStackViewMemory), @"Resident Stack View Memory",
                                                        @(residentTrashMemory), @"Resident Trash Memory",
                                                        @(residentImageCacheMemory), @"Resident Image Cache Memory",
                                                        @(accountedResidentBytes), @"Resident Accounted Bytes",
                                                        @(unaccountedResidentBytes), @"Resident Unaccounted Bytes",
                                                        @(numberInImageCache), @"Number In Image Cache",
                                                        @(numberOfLoadedPagePreviews), @"Number Of Loaded Page Previews",
                                                        @(numberOfLoadedPageStates), @"Number Of Loaded Page States",
                                                        @(numberOfItemsInTrash), @"Number Of Items In Trash",
                                                        @(totalBytesInScrapBackgrounds), @"Total Bytes In Scrap Backgrounds",
                                                        @(totalBytesInVBOs), @"Total Bytes In VBOs",
                                                        @(totalBytesInTextures), @"Total Bytes In Textures",
                                                        @(maxTotalBytesInScrapBackgrounds), @"Max Total Bytes In Scrap Backgrounds",
                                                        @(maxTotalBytesInVBOs), @"Max Total Bytes In VBOs",
                                                        @(maxTotalBytesInTextures), @"Max Total Bytes In Textures",
                                                        @(maxVirtualSize), @"Max Virtual Size",
                                                        @(maxResidentSize), @"Max Resident Size",
                                                        @(maxAccountedResidentBytes), @"Max Resident Accounted Bytes",
                                                        @(maxUnaccountedResidentBytes), @"Max Resident Unaccounted Bytes",
                                                        nil]];
}

-(void) memoryWarning{
    [[Mixpanel sharedInstance] track:kMPEventMemoryWarning];
}

@end
