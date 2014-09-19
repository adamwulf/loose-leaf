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
#import "NSThread+BlockAdditions.h"
#import "NSArray+Map.h"

@implementation MMAbstractSidebarContentView{
    NSMutableDictionary* currentRowForAlbum;
}

@synthesize delegate;
@synthesize isShowing;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        currentRowForAlbum = [NSMutableDictionary dictionary];
        albumListScrollView = [[MMCachedRowsScrollView alloc] initWithFrame:self.bounds withRowHeight:ceilf(self.bounds.size.width / 3) andMargins:kTopBottomMargin];
        albumListScrollView.dataSource = self;
        
        photoListScrollView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:[self photosLayout]];
        photoListScrollView.dataSource = self;
        photoListScrollView.delegate = self;
        photoListScrollView.alpha = 0;
        photoListScrollView.backgroundColor = [UIColor clearColor];
        
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
                               
-(UICollectionViewLayout*) photosLayout{
    return [[UICollectionViewFlowLayout alloc] init];
}

-(CGFloat) rowHeight{
    return ceilf(self.bounds.size.width / 2);
}

-(void) reset:(BOOL)animated{
    albumListScrollView.alpha = 1;
    photoListScrollView.alpha = 0;
}

-(void) show:(BOOL)animated{
    [[MMPhotoManager sharedInstance] initializeAlbumCache];
    [self updatePhotoRotation:NO];
    isShowing = YES;
}

-(void) hide:(BOOL)animated{
//    albumListScrollView.alpha = 1;
//    photoListScrollView.alpha = 0;
//    currentAlbum = nil;
    isShowing = NO;
}

-(void) killMemory{
    [albumListScrollView killMemory];
}

#pragma mark - MMPhotoManagerDelegate

-(void) doneLoadingPhotoAlbums{
    [albumListScrollView refreshVisibleRows];
    [albumListScrollView enumerateVisibleRowsWithBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self updateRow:obj atIndex:idx forFrame:[obj frame] forScrollView:albumListScrollView];
    }];
    if(photoListScrollView.alpha){
        [photoListScrollView reloadData];
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
    
    [photoListScrollView reloadData];
    
    [UIView animateWithDuration:.3 animations:^{
        albumListScrollView.alpha = 0;
        photoListScrollView.alpha = 1;
    }  completion:^(BOOL finished){
        [self setUserInteractionEnabled:YES];
    }];
}

#pragma mark - MMPhotoRowViewDelegate

-(void) photoRowWasTapped:(MMPhotoRowView*)row forAsset:(ALAsset *)asset forImage:(MMBufferedImageView *)bufferedImage withRotation:(CGFloat)rotation{
    [delegate photoWasTapped:asset fromView:bufferedImage withRotation:rotation fromContainer:self];
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
            [currentAlbumRow updatePhotoRotation];
        }
        return currentAlbumRow;
    }else{
        MMPhotoRowView* currentPhotoRow = (MMPhotoRowView*)currentRow;
        if(!currentPhotoRow){
            currentPhotoRow = [[MMPhotoRowView alloc] initWithFrame:frame];
            currentPhotoRow.delegate = self;
        }
        [currentPhotoRow loadPhotosFromAlbum:currentAlbum atRow:index];
        [currentPhotoRow updatePhotoRotation];
        return currentPhotoRow;
    }
}

#pragma mark - Rotation

-(void) updatePhotoRotation:(BOOL)animated{
    
    void(^updateVisibleRowsWithRotation)() = ^{
        if(photoListScrollView.alpha){
            [photoListScrollView.visibleCells mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
                if([obj respondsToSelector:@selector(updatePhotoRotation)]){
                    [obj updatePhotoRotation];
                }
                return obj;
            }];
        }else if(albumListScrollView.alpha){
            [albumListScrollView enumerateVisibleRowsWithBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if([obj respondsToSelector:@selector(updatePhotoRotation)]){
                    [obj updatePhotoRotation];
                }
            }];
        }
    };
    
    if(animated){
        [[NSThread mainThread] performBlock:^{
            [UIView animateWithDuration:.3 animations:updateVisibleRowsWithRotation];
        }];
    }else{
        [[NSThread mainThread] performBlock:^{
            updateVisibleRowsWithRotation();
        }];
    }
}

-(NSString*) description{
    @throw kAbstractMethodException;
}



#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    @throw kAbstractMethodException;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
//    @throw kAbstractMethodException;
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    @throw kAbstractMethodException;
}


#pragma mark - UICollectionViewDelegate








@end
