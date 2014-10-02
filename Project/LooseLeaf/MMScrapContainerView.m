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

@implementation MMScrapContainerView{
    // must be weak, otherwise its a circular ref
    // with the page
    __weak MMScrappedPaperView* page;
}

- (id)initWithFrame:(CGRect)frame forPageDelegate:(MMScrappedPaperView*)_page{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        page = _page;
    }
    return self;
}

-(void) addSubview:(UIView *)view{
    if([view isKindOfClass:[MMScrapView class]]){
        MMScrapView* scrap = (MMScrapView*)view;
        if(page && scrap.state.scrapsOnPaperState != page.scrapsOnPaperState){
            @throw [NSException exceptionWithName:@"InvalidSubviewException" reason:@"ScrapContainerViews was given a scrap that doesn't belong" userInfo:nil];
        }
        [super addSubview:view];
    }else{
        @throw [NSException exceptionWithName:@"InvalidSubviewException" reason:@"ScrapContainerViews can only hold scraps" userInfo:nil];
    }
}

@end
