//
//  MMCameraSidebarContentView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 4/9/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCameraSidebarContentView.h"
#import "MMPhotoManager.h"
#import "MMPhotoRowView.h"

@implementation MMCameraSidebarContentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // don't use the albumListScrollView at all
        [albumListScrollView removeFromSuperview];
        albumListScrollView = nil;
        
        photoListScrollView.alpha = 1;
        
        currentAlbum = [[MMPhotoManager sharedInstace] cameraRoll];
    }
    return self;
}

-(void) show:(BOOL)animated{
    albumListScrollView.alpha = 0;
    photoListScrollView.alpha = 1;
    [[MMPhotoManager sharedInstace] initializeAlbumCache:nil];
}

-(void) hide:(BOOL)animated{
    albumListScrollView.alpha = 0;
    photoListScrollView.alpha = 1;
}


#pragma mark - MMPhotoManagerDelegate

-(void) doneLoadingPhotoAlbums{
    currentAlbum = [[MMPhotoManager sharedInstace] cameraRoll];
    if(photoListScrollView.alpha){
        [photoListScrollView refreshVisibleRows];
        [photoListScrollView enumerateVisibleRowsWithBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            // force invalidate the row's cache
            [(MMPhotoRowView*)obj unload];
            // now load the proper row info again
            [self updateRow:obj atIndex:idx forFrame:[obj frame] forScrollView:photoListScrollView];
        }];
    }
}

-(void) albumUpdated:(MMPhotoAlbum *)album{
    if(album == [[MMPhotoManager sharedInstace] cameraRoll]){
        currentAlbum = album;
        [self doneLoadingPhotoAlbums];
    }
}


#pragma mark - MMCachedRowsScrollViewDataSource

-(NSInteger) numberOfRowsFor:(MMCachedRowsScrollView*)scrollView{
    return ceilf([[MMPhotoManager sharedInstace] cameraRoll].numberOfPhotos / 2.0);
}

-(void) prepareRowForReuse:(UIView*)aRow forScrollView:(MMCachedRowsScrollView*)scrollView{
    return [super prepareRowForReuse:aRow forScrollView:scrollView];
}

-(UIView*) updateRow:(UIView*)currentRow atIndex:(NSInteger)index forFrame:(CGRect)frame forScrollView:(MMCachedRowsScrollView*)scrollView{
    return [super updateRow:currentRow atIndex:index forFrame:frame forScrollView:scrollView];
}


@end
