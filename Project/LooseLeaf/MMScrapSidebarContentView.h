//
//  MMScrapBezelMenuView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/5/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMScrapsInBezelContainerView.h"

@interface MMScrapSidebarContentView : UIView{
    __weak MMScrapsInBezelContainerView* delegate;
}

@property (nonatomic, weak) MMScrapsInBezelContainerView* delegate;
@property (nonatomic, assign) NSInteger columnCount;

-(void) prepareContentView;

-(void) flashScrollIndicators;

@end
