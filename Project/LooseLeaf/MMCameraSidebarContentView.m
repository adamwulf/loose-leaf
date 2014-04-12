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
#import "AVCamView.h"
#import "MMBorderedCamView.h"
#import "Constants.h"
#import "MMFlipCameraButton.h"
#import "MMImageSidebarContainerView.h"
#import "NSThread+BlockAdditions.h"

#define kCameraMargin 10

@implementation MMCameraSidebarContentView{
    MMBorderedCamView* cameraRow;
    MMFlipCameraButton* flipButton;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // don't use the albumListScrollView at all
        [albumListScrollView removeFromSuperview];
        albumListScrollView = nil;
        
        photoListScrollView.alpha = 1;
        
        currentAlbum = [[MMPhotoManager sharedInstace] cameraRoll];
        
        CGRect cameraViewFr = [self cameraViewFr];
        
        
        flipButton = [[MMFlipCameraButton alloc] initWithFrame:CGRectMake(self.frame.size.width - kWidthOfSidebarButton - kWidthOfSidebarButtonBuffer,
                                                                          floorf((cameraViewFr.size.height - kWidthOfSidebarButton) / 2),
                                                                          kWidthOfSidebarButton, kWidthOfSidebarButton)];
        [flipButton addTarget:self action:@selector(changeCamera) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:flipButton];
    }
    return self;
}

-(CGRect) cameraViewFr{
    CGFloat ratio = [UIScreen mainScreen].bounds.size.width / [UIScreen mainScreen].bounds.size.height;
    CGRect cameraViewFr = CGRectZero;
    cameraViewFr.size.width = ratio * (photoListScrollView.rowHeight - kCameraMargin) * 2;
    cameraViewFr.size.height = (photoListScrollView.rowHeight - kCameraMargin) * 2;
    return cameraViewFr;
}

-(void) show:(BOOL)animated{
    
    cameraRow = [[MMBorderedCamView alloc] initWithFrame:[self cameraViewFr]];
    cameraRow.delegate = self;
    cameraRow.rotation = RandomPhotoRotation/2;
    cameraRow.center = CGPointMake((self.frame.size.width-kWidthOfSidebarButton)/2, kCameraMargin + cameraRow.bounds.size.height/2);
    [photoListScrollView addSubview:cameraRow];
    
    albumListScrollView.alpha = 0;
    photoListScrollView.alpha = 1;
    [[MMPhotoManager sharedInstace] initializeAlbumCache:nil];
    
    [[NSThread mainThread] performBlock:^{
        currentAlbum = [[MMPhotoManager sharedInstace] cameraRoll];
        [self doneLoadingPhotoAlbums];
    } afterDelay:.1];
}

-(void) hide:(BOOL)animated{
    albumListScrollView.alpha = 0;
    photoListScrollView.alpha = 1;
    
    [cameraRow removeFromSuperview];
    cameraRow.delegate = nil;
    cameraRow = nil;

    [[NSThread mainThread] performBlock:^{
        [photoListScrollView enumerateVisibleRowsWithBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if(![obj isEqual:[NSNull null]]){
                // force invalidate the row's cache
                if([obj respondsToSelector:@selector(unload)]){
                    [(MMPhotoRowView*)obj unload];
                }
            }
        }];
    } afterDelay:.1];
}

-(void) changeCamera{
    [cameraRow changeCamera];
}


#pragma mark - MMPhotoManagerDelegate

-(void) doneLoadingPhotoAlbums{
    currentAlbum = [[MMPhotoManager sharedInstace] cameraRoll];
    if(cameraRow && photoListScrollView.alpha){
        [photoListScrollView refreshVisibleRows];
        [photoListScrollView enumerateVisibleRowsWithBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if(![obj isEqual:[NSNull null]]){
                // force invalidate the row's cache
                if([obj respondsToSelector:@selector(unload)]){
                    [(MMPhotoRowView*)obj unload];
                }
                // now load the proper row info again
                [self updateRow:obj atIndex:idx forFrame:[obj frame] forScrollView:photoListScrollView];
            }else if(idx == 1){
                [self updateRow:nil atIndex:0 forFrame:CGRectZero forScrollView:photoListScrollView];
            }
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
    // add two for the camera row at the top
    return 2 + ceilf([[MMPhotoManager sharedInstace] cameraRoll].numberOfPhotos / 2.0);
}

-(BOOL) prepareRowForReuse:(UIView*)aRow forScrollView:(MMCachedRowsScrollView*)scrollView{
    if(aRow.tag == 0 || aRow.tag == 1){
        return NO;
    }
    return [super prepareRowForReuse:aRow forScrollView:scrollView];
}

-(UIView*) updateRow:(UIView*)currentRow atIndex:(NSInteger)index forFrame:(CGRect)frame forScrollView:(MMCachedRowsScrollView*)scrollView{
//    NSLog(@"fetching photo row for index: %d", index);
    if(index == 0 || index == 1){
        // this space is taken up by the camera row, so
        // return nil
        return nil;
    }
    // adjust for the 2 extra rows that are taken up by the camera input
    return [super updateRow:currentRow atIndex:index - 2 forFrame:frame forScrollView:scrollView];
}

#pragma mark - MMCamViewDelegate

-(void) didTakePicture:(UIImage*)img{
    NSLog(@"got picture %p", img);
    [self.delegate pictureTakeWithCamera:img fromView:cameraRow];
}


@end
