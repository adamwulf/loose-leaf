//
//  MMScrapContainerView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/9/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMScrapContainerView.h"
#import "MMScrappedPaperView.h"
#import "MMScrapView.h"


@implementation MMScrapContainerView {
    // must be weak, otherwise its a circular ref
    // with the page
    __weak MMScrapsOnPaperState* scrapsOnPaperState;
}

- (id)initWithFrame:(CGRect)frame forScrapsOnPaperState:(MMScrapsOnPaperState*)_scrapsOnPaperState {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        scrapsOnPaperState = _scrapsOnPaperState;
    }
    return self;
}

- (void)addSubview:(UIView*)view {
    if ([view isKindOfClass:[MMScrapView class]]) {
        MMScrapView* scrap = (MMScrapView*)view;
        if (scrapsOnPaperState && scrap.state.scrapsOnPaperState != scrapsOnPaperState) {
            @throw [NSException exceptionWithName:@"InvalidSubviewException" reason:@"ScrapContainerViews was given a scrap that doesn't belong" userInfo:nil];
        }
        [super addSubview:view];
    } else if (view) {
        @throw [NSException exceptionWithName:@"InvalidSubviewException" reason:[NSString stringWithFormat:@"ScrapContainerViews can only hold scraps, given %@", NSStringFromClass([view class])] userInfo:nil];
    } else {
        @throw [NSException exceptionWithName:@"InvalidSubviewException" reason:@"ScrapContainerViews can only hold scraps, given (null)" userInfo:nil];
    }
}

@end
