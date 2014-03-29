//
//  MMImageSidebarContentView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/29/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMSlidingSidebarContainerViewDelegate.h"

@interface MMImageSidebarContentView : UIView{
    __weak NSObject<MMSlidingSidebarContainerViewDelegate>* delegate;
}

@property (nonatomic, weak) NSObject<MMSlidingSidebarContainerViewDelegate>* delegate;

@end
