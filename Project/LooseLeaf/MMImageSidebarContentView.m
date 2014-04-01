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
        scrollView.delegate = self;
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
    [self validateRowsForCurrentOffset];
}

-(void) loadedPreviewPhotosFor:(MMPhotoAlbum *)album{
    NSInteger index = [self indexForAlbum:album];
    if([scrollView rowIndexIsVisible:index]){
        MMAlbumRowView* row = [self rowAtIndex:index];
        [row loadedPreviewPhotos];
    }
}

#pragma mark - Row Management

-(MMAlbumRowView*) rowAtIndex:(NSInteger) index{
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

-(void) validateRowsForCurrentOffset{
    // remove invisible rows
    for(MMAlbumRowView* row in scrollView.subviews){
        if(![scrollView rowIndexIsVisible:row.tag]){
            row.hidden = YES;
            if(row.album){
                [currentRowForAlbum removeObjectForKey:row.album.persistentId];
                [row.album unloadPreviewPhotos];
            }
            [currentRowAtIndex removeObjectForKey:[NSNumber numberWithInt:row.tag]];
            row.album = nil;
            [bufferOfUnusedAlbumRows addObject:row];
        }
    }
    
    // loop through visible albums
    // and make sure row is at the right place
    CGFloat currOffset = scrollView.contentOffset.y;
    while([scrollView rowIndexIsVisible:[scrollView rowIndexForY:currOffset]]){
        NSInteger currIndex = [scrollView rowIndexForY:currOffset];
        if(currIndex >= 0){
            // load the row
            [self rowAtIndex:currIndex];
        }
        currOffset += scrollView.rowHeight;
    }
    
    
    NSInteger totalAlbumCount = [[[MMPhotoManager sharedInstace] albums] count] +
                                [[[MMPhotoManager sharedInstace] events] count] +
                                [[[MMPhotoManager sharedInstace] faces] count];
    CGFloat contentHeight = 2*kTopBottomMargin + scrollView.rowHeight * totalAlbumCount;
    scrollView.contentSize = CGSizeMake(self.bounds.size.width, contentHeight);
}


#pragma mark - UIScrollViewDelegate

-(void) scrollViewDidScroll:(UIScrollView *)_scrollView{
    [self validateRowsForCurrentOffset];
}

#pragma mark - MMAlbumRowViewDelegate

-(void) rowWasTapped:(MMAlbumRowView*)row{
    NSLog(@"row was tapped: %@", row.album.name);
}


@end
