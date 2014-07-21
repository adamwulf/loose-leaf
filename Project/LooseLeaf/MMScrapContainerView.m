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
    MMScrappedPaperView* page;
}

- (id)initWithFrame:(CGRect)frame andPage:(MMScrappedPaperView*)_page{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        page = _page;
        self.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:.4];
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
