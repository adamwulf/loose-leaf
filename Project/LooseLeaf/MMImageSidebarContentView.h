//
//  MMImageSidebarContentView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/29/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMSlidingSidebarContainerViewDelegate.h"
#import "MMCachedRowsScrollViewDataSource.h"
#import "MMPhotoManagerDelegate.h"
#import "MMAlbumRowViewDelegate.h"

@class MMImageSidebarContainerView;

@interface MMImageSidebarContentView : UIView<MMPhotoManagerDelegate,MMAlbumRowViewDelegate,MMCachedRowsScrollViewDataSource>{
    __weak MMImageSidebarContainerView* delegate;
}

@property (nonatomic, weak) MMImageSidebarContainerView* delegate;

-(void) show:(BOOL)animated;

-(void) hide:(BOOL)animated;
    
@end
