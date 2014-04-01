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
#import "MMImageSidebarContainerView.h"

#define kTopBottomMargin 50

@implementation MMImageSidebarContentView{
    MMPhotoAlbumListScrollView* scrollView;
    NSMutableArray* bufferOfUnusedAlbumRows;
    NSMutableDictionary* currentRowForAlbum;
    NSMutableDictionary* currentRowAtIndex;
}

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        bufferOfUnusedAlbumRows = [NSMutableArray array];
        currentRowForAlbum = [NSMutableDictionary dictionary];
        currentRowAtIndex = [NSMutableDictionary dictionary];
        [MMPhotoManager sharedInstace].delegate = self;
        scrollView = [[MMPhotoAlbumListScrollView alloc] initWithFrame:self.bounds withRowHeight:ceilf(self.bounds.size.width / 3) andMargins:kTopBottomMargin];
        scrollView.dataSource = self;
        [self addSubview:scrollView];
    }
    return self;
}


-(void) show:(BOOL)animated{
    [[MMPhotoManager sharedInstace] initializeAlbumCache:nil];
}

-(void) hide:(BOOL)animated{

}



#pragma mark - MMPhotoManagerDelegate

-(void) doneLoadingPhotoAlbums{
    [scrollView refreshVisibleRows];
}

-(void) loadedPreviewPhotosFor:(MMPhotoAlbum *)album{
    NSInteger index = [self indexForAlbum:album];
    if([scrollView rowIndexIsVisible:index]){
        MMAlbumRowView* row = (MMAlbumRowView*) [self rowAtIndex:index];
        [row loadedPreviewPhotos];
    }
}

#pragma mark - Row Management

-(UIView*) rowAtIndex:(NSInteger) index{
    MMAlbumRowView* row = [currentRowAtIndex objectForKey:[NSNumber numberWithInt:index]];
    if(!row){
        CGRect fr = CGRectMake(0, kTopBottomMargin + index * scrollView.rowHeight, self.bounds.size.width, scrollView.rowHeight);
        if([bufferOfUnusedAlbumRows count]){
            row = [bufferOfUnusedAlbumRows lastObject];
            [bufferOfUnusedAlbumRows removeLastObject];
            row.frame = fr;
        }else{
            row = [[MMAlbumRowView alloc] initWithFrame:fr];
            row.delegate = self;
            [scrollView addSubview:row];
        }
        row.tag = index;
        [currentRowAtIndex setObject:row forKey:[NSNumber numberWithInt:index]];
        row.hidden = NO;
        if([scrollView rowIndexIsVisible:index]){
            // make sure the album is set, but only if it's visible
            // and if we need to
            MMPhotoAlbum* album = [self albumAtIndex:index];
            if(row.album != album){
                if(row.album){
                    [currentRowForAlbum removeObjectForKey:row.album.persistentId];
                }
                row.album = album;
                if(row.album){
                    [currentRowForAlbum setObject:row forKey:row.album.persistentId];
                }
            }
        }
    }
    return row;
}

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
    NSLog(@"row was tapped: %@", row.album.name);
}

#pragma mark - MMPhotoAlbumListScrollViewDataSource

-(NSInteger) numberOfRowsFor:(MMPhotoAlbumListScrollView*)scrollView{
    return [[[MMPhotoManager sharedInstace] albums] count] +
    [[[MMPhotoManager sharedInstace] events] count] +
    [[[MMPhotoManager sharedInstace] faces] count];
}

// called when a row is hidden in the scrollview
// and may be re-used with different model data later
-(void) prepareRowForReuse:(UIView*)aRow forScrollView:(MMPhotoAlbumListScrollView*)scrollView{
    MMAlbumRowView* row = (MMAlbumRowView*)aRow;
    if(row.album){
        [currentRowForAlbum removeObjectForKey:row.album.persistentId];
        [row.album unloadPreviewPhotos];
        row.album = nil;
    }
}


-(NSMutableArray*) bufferOfUnusedAlbumRows{
    return bufferOfUnusedAlbumRows;
}

-(NSMutableDictionary*) currentRowAtIndex{
    return currentRowAtIndex;
}

@end
