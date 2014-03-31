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
        scrollView = [[MMPhotoAlbumListScrollView alloc] initWithFrame:self.bounds];
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
    if([self indexIsVisible:index]){
        MMAlbumRowView* row = [self rowAtIndex:index];
        [row loadedPreviewPhotos];
    }
}

#pragma mark - Row Management

-(CGFloat) rowHeight{
    return ceilf(self.bounds.size.width / 3);
}

-(BOOL) indexIsVisible:(NSInteger)index{
    CGFloat minY = kTopBottomMargin + index * [self rowHeight];
    CGFloat maxY = minY + [self rowHeight];
    if(minY < scrollView.contentOffset.y + scrollView.bounds.size.height &&
       maxY > scrollView.contentOffset.y){
        return YES;
    }
    return NO;
}

-(BOOL) isRowVisible:(MMAlbumRowView*)row{
    if(row.superview && [self indexIsVisible:row.tag]){
        return YES;
    }
    return NO;
}

-(MMAlbumRowView*) rowForAlbum:(MMPhotoAlbum*)album{
    MMAlbumRowView* r = [currentRowForAlbum objectForKey:album.persistentId];
    if(!r){
        if([bufferOfUnusedAlbumRows count]){
            r = [bufferOfUnusedAlbumRows lastObject];
            [bufferOfUnusedAlbumRows removeLastObject];
        }else{
            r = [[MMAlbumRowView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, [self rowHeight])];
        }
        r.album = album;
        [currentRowForAlbum setObject:r forKey:album.persistentId];
    }
    return r;
}

-(MMAlbumRowView*) rowAtIndex:(NSInteger) index{
    MMAlbumRowView* r = [currentRowAtIndex objectForKey:[NSNumber numberWithInt:index]];
    if(!r){
        CGRect fr = CGRectMake(0, kTopBottomMargin + index * [self rowHeight], self.bounds.size.width, [self rowHeight]);
        if([bufferOfUnusedAlbumRows count]){
            r = [bufferOfUnusedAlbumRows lastObject];
            [bufferOfUnusedAlbumRows removeLastObject];
            r.frame = fr;
        }else{
            r = [[MMAlbumRowView alloc] initWithFrame:fr];
        }
        r.tag = index;
        [currentRowAtIndex setObject:r forKey:[NSNumber numberWithInt:index]];
        [scrollView addSubview:r];
    }
    return r;
}

-(NSInteger) indexForY:(CGFloat)y{
    NSInteger currIndex = floorf((y - kTopBottomMargin) / [self rowHeight]);
    return currIndex;
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
        if(![self isRowVisible:row]){
            [row removeFromSuperview];
            if(row.album){
                [currentRowForAlbum removeObjectForKey:row.album.persistentId];
            }
            [currentRowAtIndex removeObjectForKey:[NSNumber numberWithInt:row.tag]];
            row.album = nil;
            [bufferOfUnusedAlbumRows addObject:row];
        }
    }
    
    // loop through visible albums
    // and make sure row is at the right place
    CGFloat currOffset = scrollView.contentOffset.y;
    while([self indexIsVisible:[self indexForY:currOffset]]){
        NSInteger currIndex = [self indexForY:currOffset];
        if(currIndex >= 0){
            MMAlbumRowView* row = [self rowAtIndex:currIndex];
            MMPhotoAlbum* album = [self albumAtIndex:currIndex];
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
        currOffset += [self rowHeight];
    }
    
    
    NSInteger totalAlbumCount = [[[MMPhotoManager sharedInstace] albums] count] +
                                [[[MMPhotoManager sharedInstace] events] count] +
                                [[[MMPhotoManager sharedInstace] faces] count];
    CGFloat contentHeight = 2*kTopBottomMargin + [self rowHeight] * totalAlbumCount;
    scrollView.contentSize = CGSizeMake(self.bounds.size.width, contentHeight);
}


#pragma mark - UIScrollViewDelegate

-(void) scrollViewDidScroll:(UIScrollView *)_scrollView{
    [self validateRowsForCurrentOffset];
}

@end
