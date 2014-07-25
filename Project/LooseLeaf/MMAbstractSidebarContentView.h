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
#import "MMCachedRowsScrollView.h"
#import "MMPhotoManagerDelegate.h"
#import "MMAlbumRowViewDelegate.h"
#import "MMPhotoRowViewDelegate.h"

#define kTopBottomMargin 20

@class MMImageSidebarContainerView;

@interface MMAbstractSidebarContentView : UIView<MMPhotoManagerDelegate,MMAlbumRowViewDelegate,MMPhotoRowViewDelegate,MMCachedRowsScrollViewDataSource>{
    MMPhotoAlbum* currentAlbum;
    MMCachedRowsScrollView* albumListScrollView;
    MMCachedRowsScrollView* photoListScrollView;
    __weak MMImageSidebarContainerView* delegate;
    BOOL isShowing;
}

@property (nonatomic, weak) MMImageSidebarContainerView* delegate;
@property (nonatomic, readonly) BOOL isShowing;

-(void) reset:(BOOL)animated;

-(void) show:(BOOL)animated;

-(void) hide:(BOOL)animated;

-(void) killMemory;

-(void) updatePhotoRotation:(BOOL)animated;

// abstract

-(NSInteger) indexForAlbum:(MMPhotoAlbum*)album;

-(MMPhotoAlbum*) albumAtIndex:(NSInteger)index;

@end
