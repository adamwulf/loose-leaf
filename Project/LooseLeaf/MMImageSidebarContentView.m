//
//  MMImageSidebarContentView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/29/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMImageSidebarContentView.h"
#import "MMPhotoManager.h"
#import "MMPhotoAlbumListScrollView.h"
#import "MMAlbumRowView.h"
#import "MMPhotoRowView.h"
#import "MMImageSidebarContainerView.h"

#define kTopBottomMargin 50

@implementation MMImageSidebarContentView{
    MMPhotoAlbumListScrollView* albumListScrollView;
    MMPhotoAlbumListScrollView* photoListScrollView;
    NSMutableDictionary* currentRowForAlbum;
    
    MMPhotoAlbum* currentAlbum;
}

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        currentRowForAlbum = [NSMutableDictionary dictionary];
        [MMPhotoManager sharedInstace].delegate = self;
        albumListScrollView = [[MMPhotoAlbumListScrollView alloc] initWithFrame:self.bounds withRowHeight:ceilf(self.bounds.size.width / 3) andMargins:kTopBottomMargin];
        albumListScrollView.dataSource = self;
        
        photoListScrollView = [[MMPhotoAlbumListScrollView alloc] initWithFrame:self.bounds withRowHeight:ceilf(self.bounds.size.width / 2) andMargins:kTopBottomMargin];
        photoListScrollView.dataSource = self;
        photoListScrollView.alpha = 0;
        
        currentAlbum = nil;
        
        [self addSubview:albumListScrollView];
        [self addSubview:photoListScrollView];
    }
    return self;
}


-(void) show:(BOOL)animated{
    albumListScrollView.alpha = 1;
    photoListScrollView.alpha = 0;
    [[MMPhotoManager sharedInstace] initializeAlbumCache:nil];
}

-(void) hide:(BOOL)animated{
    currentAlbum = nil;
}



#pragma mark - MMPhotoManagerDelegate

-(void) doneLoadingPhotoAlbums{
    NSLog(@"refreshing table rows");
    [albumListScrollView refreshVisibleRows];
    [albumListScrollView enumerateVisibleRowsWithBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self updateRow:obj atIndex:idx forFrame:[obj frame] forScrollView:albumListScrollView];
    }];
}

-(void) loadedPreviewPhotosFor:(MMPhotoAlbum *)album{
    NSInteger index = [self indexForAlbum:album];
    if([albumListScrollView rowIndexIsVisible:index]){
        MMAlbumRowView* row = (MMAlbumRowView*) [albumListScrollView rowAtIndex:index];
        [row loadedPreviewPhotos];
    }
}

#pragma mark - Row Management

-(NSInteger) indexForAlbum:(MMPhotoAlbum*)album{
    if(album.type == ALAssetsGroupAlbum){
        return [[[MMPhotoManager sharedInstace] albums] indexOfObject:album];
    }
    if(album.type == ALAssetsGroupEvent){
        return [[[MMPhotoManager sharedInstace] events] indexOfObject:album] + [[[MMPhotoManager sharedInstace] albums] count];
    }
    if(album.type == ALAssetsGroupFaces){
        return [[[MMPhotoManager sharedInstace] faces] indexOfObject:album] +
                [[[MMPhotoManager sharedInstace] albums] count] +
                [[[MMPhotoManager sharedInstace] events] count];
    }
    return -1;
}

-(MMPhotoAlbum*) albumAtIndex:(NSInteger)index{
    if(index >= [[[MMPhotoManager sharedInstace] albums] count]){
        index -= [[[MMPhotoManager sharedInstace] albums] count];
    }else{
        return [[[MMPhotoManager sharedInstace] albums] objectAtIndex:index];
    }

    if(index >= [[[MMPhotoManager sharedInstace] events] count]){
        index -= [[[MMPhotoManager sharedInstace] events] count];
    }else{
        return [[[MMPhotoManager sharedInstace] events] objectAtIndex:index];
    }

    if(index >= [[[MMPhotoManager sharedInstace] faces] count]){
        index -= [[[MMPhotoManager sharedInstace] faces] count];
    }else{
        return [[[MMPhotoManager sharedInstace] faces] objectAtIndex:index];
    }
    return nil;
}


#pragma mark - MMAlbumRowViewDelegate

-(void) rowWasTapped:(MMAlbumRowView*)row{
    [self setUserInteractionEnabled:NO];
    NSLog(@"row was tapped: %@", row.album.name);
    currentAlbum = row.album;
    [photoListScrollView refreshVisibleRows];
    [photoListScrollView enumerateVisibleRowsWithBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self updateRow:obj atIndex:idx forFrame:[obj frame] forScrollView:photoListScrollView];
    }];
    [UIView animateWithDuration:.3 animations:^{
        albumListScrollView.alpha = 0;
        photoListScrollView.alpha = 1;
    }  completion:^(BOOL finished){
        [self setUserInteractionEnabled:YES];
    }];
}

#pragma mark - MMPhotoAlbumListScrollViewDataSource

-(NSInteger) numberOfRowsFor:(MMPhotoAlbumListScrollView*)scrollView{
    if(scrollView == albumListScrollView){
        return [[[MMPhotoManager sharedInstace] albums] count] +
        [[[MMPhotoManager sharedInstace] events] count] +
        [[[MMPhotoManager sharedInstace] faces] count];
    }else{
        return ceilf(currentAlbum.numberOfPhotos / 2.0);
    }
}

// called when a row is hidden in the scrollview
// and may be re-used with different model data later
-(void) prepareRowForReuse:(UIView*)aRow forScrollView:(MMPhotoAlbumListScrollView*)scrollView{
    if(scrollView == albumListScrollView){
        MMAlbumRowView* row = (MMAlbumRowView*)aRow;
        if(row.album){
            [currentRowForAlbum removeObjectForKey:row.album.persistentId];
            [row.album unloadPreviewPhotos];
            row.album = nil;
        }
    }else{
        // noop
    }
}

// currentRow may or maynot be nil. if nil, then
// create a view and return it. otehrwise use the
// existing view, update it, and return it
-(UIView*) updateRow:(UIView*)currentRow atIndex:(NSInteger)index forFrame:(CGRect)frame forScrollView:(MMPhotoAlbumListScrollView*)scrollView{
    if(scrollView == albumListScrollView){
        MMAlbumRowView* currentAlbumRow = (MMAlbumRowView*)currentRow;
        if(!currentAlbumRow){
            currentAlbumRow = [[MMAlbumRowView alloc] initWithFrame:frame];
            currentAlbumRow.delegate = self;
        }
        if([albumListScrollView rowIndexIsVisible:index]){
            // make sure the album is set, but only if it's visible
            // and if we need to
            MMPhotoAlbum* album = [self albumAtIndex:index];
            if(currentAlbumRow.album != album){
                if(currentAlbumRow.album){
                    [currentRowForAlbum removeObjectForKey:currentAlbumRow.album.persistentId];
                }
                currentAlbumRow.album = album;
                if(currentAlbumRow.album){
                    [currentRowForAlbum setObject:currentAlbumRow forKey:currentAlbumRow.album.persistentId];
                }
            }
        }
        return currentAlbumRow;
    }else{
        if(!currentRow){
            currentRow = [[MMPhotoRowView alloc] initWithFrame:frame];
        }
        return currentRow;
    }
}

@end
