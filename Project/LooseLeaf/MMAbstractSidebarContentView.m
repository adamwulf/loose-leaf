//
//  MMImageSidebarContentView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/29/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMAbstractSidebarContentView.h"
#import "MMPhotoManager.h"
#import "MMCachedRowsScrollView.h"
#import "MMAlbumRowView.h"
#import "MMPhotoRowView.h"
#import "MMBufferedImageView.h"
#import "MMImageSidebarContainerView.h"
#import "ALAsset+Thumbnail.h"
#import "Constants.h"

@implementation MMAbstractSidebarContentView{
    NSMutableDictionary* currentRowForAlbum;
}

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        currentRowForAlbum = [NSMutableDictionary dictionary];
        albumListScrollView = [[MMCachedRowsScrollView alloc] initWithFrame:self.bounds withRowHeight:ceilf(self.bounds.size.width / 3) andMargins:kTopBottomMargin];
        albumListScrollView.dataSource = self;
        
        photoListScrollView = [[MMCachedRowsScrollView alloc] initWithFrame:self.bounds withRowHeight:ceilf(self.bounds.size.width / 2) andMargins:kTopBottomMargin];
        photoListScrollView.dataSource = self;
        photoListScrollView.alpha = 0;
        
        currentAlbum = nil;
        
        [self addSubview:albumListScrollView];
        [self addSubview:photoListScrollView];
        
        
        NSObject * transparent = (NSObject *) [[UIColor colorWithWhite:0 alpha:0] CGColor];
        NSObject * opaque = (NSObject *) [[UIColor colorWithWhite:0 alpha:1] CGColor];
        
        CALayer * maskLayer = [CALayer layer];
        maskLayer.frame = self.bounds;
        
        CAGradientLayer * gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = CGRectMake(self.bounds.origin.x, 0,
                                         self.bounds.size.width, self.bounds.size.height);
        
        gradientLayer.colors = [NSArray arrayWithObjects: transparent, opaque, nil];
        
        CGFloat fadePercentage = kTopBottomMargin / self.bounds.size.height;
        // Set percentage of scrollview that fades at top & bottom
        gradientLayer.locations = [NSArray arrayWithObjects:
                                   [NSNumber numberWithFloat:0],
                                   [NSNumber numberWithFloat:fadePercentage], nil];
        
        [maskLayer addSublayer:gradientLayer];
        self.layer.mask = maskLayer;

    }
    return self;
}


-(void) show:(BOOL)animated{
    albumListScrollView.alpha = 1;
    photoListScrollView.alpha = 0;
    [[MMPhotoManager sharedInstace] initializeAlbumCache:nil];
}

-(void) hide:(BOOL)animated{
    albumListScrollView.alpha = 1;
    photoListScrollView.alpha = 0;
    currentAlbum = nil;
}



#pragma mark - MMPhotoManagerDelegate

-(void) doneLoadingPhotoAlbums{
    [albumListScrollView refreshVisibleRows];
    [albumListScrollView enumerateVisibleRowsWithBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self updateRow:obj atIndex:idx forFrame:[obj frame] forScrollView:albumListScrollView];
    }];
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
    NSInteger index = [self indexForAlbum:album];
    if([albumListScrollView rowIndexIsVisible:index]){
        MMAlbumRowView* row = (MMAlbumRowView*) [albumListScrollView rowAtIndex:index];
        [row loadedPreviewPhotos];
    }
}

#pragma mark - Row Management

-(NSInteger) indexForAlbum:(MMPhotoAlbum*)album{
    @throw kAbstractMethodException;
}

-(MMPhotoAlbum*) albumAtIndex:(NSInteger)index{
    @throw kAbstractMethodException;
}


#pragma mark - MMAlbumRowViewDelegate

-(void) albumRowWasTapped:(MMAlbumRowView*)row{
    [self setUserInteractionEnabled:NO];
    currentAlbum = row.album;
    photoListScrollView.contentOffset = CGPointZero;
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

#pragma mark - MMPhotoRowViewDelegate

-(void) photoRowWasTapped:(MMPhotoRowView*)row forAsset:(ALAsset *)asset forImage:(MMBufferedImageView *)bufferedImage{
    [delegate photoWasTapped:asset fromView:bufferedImage];
}

#pragma mark - MMCachedRowsScrollViewDataSource

-(NSInteger) numberOfRowsFor:(MMCachedRowsScrollView*)scrollView{
    @throw kAbstractMethodException;
}

// called when a row is hidden in the scrollview
// and may be re-used with different model data later
-(BOOL) prepareRowForReuse:(UIView*)aRow forScrollView:(MMCachedRowsScrollView*)scrollView{
    if(scrollView == albumListScrollView){
        MMAlbumRowView* row = (MMAlbumRowView*)aRow;
        if(row.album){
            [currentRowForAlbum removeObjectForKey:row.album.persistentId];
            [row.album unloadPreviewPhotos];
            row.album = nil;
        }
    }else{
        MMPhotoRowView* row = (MMPhotoRowView*)aRow;
        [row unload];
    }
    return YES;
}

// currentRow may or maynot be nil. if nil, then
// create a view and return it. otehrwise use the
// existing view, update it, and return it
-(UIView*) updateRow:(UIView*)currentRow atIndex:(NSInteger)index forFrame:(CGRect)frame forScrollView:(MMCachedRowsScrollView*)scrollView{
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
        MMPhotoRowView* currentPhotoRow = (MMPhotoRowView*)currentRow;
        if(!currentPhotoRow){
            currentPhotoRow = [[MMPhotoRowView alloc] initWithFrame:frame];
            currentPhotoRow.delegate = self;
        }
        [currentPhotoRow loadPhotosFromAlbum:currentAlbum atRow:index];
        return currentPhotoRow;
    }
}

@end
