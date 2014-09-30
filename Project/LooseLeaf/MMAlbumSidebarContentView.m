//
//  MMAlbumSidebarContentView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 4/9/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMAlbumSidebarContentView.h"
#import "MMPhotoManager.h"

@implementation MMAlbumSidebarContentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) reset:(BOOL)animated{
    if([MMPhotoManager hasPhotosPermission]){
        [super reset:animated];
    }else{
        albumListScrollView.alpha = 0;
        photoListScrollView.alpha = 1;
    }
}

#pragma mark - Row Management

-(NSInteger) indexForAlbum:(MMPhotoAlbum*)album{
    if(album.type == ALAssetsGroupAlbum){
        return [[[MMPhotoManager sharedInstance] albums] indexOfObject:album];
    }
    return -1;
}

-(MMPhotoAlbum*) albumAtIndex:(NSInteger)index{
    if(index < [[[MMPhotoManager sharedInstance] albums] count]){
        return [[[MMPhotoManager sharedInstance] albums] objectAtIndex:index];
    }
    return nil;
}

#pragma mark - MMCachedRowsScrollViewDataSource

-(NSInteger) numberOfRowsFor:(MMCachedRowsScrollView*)scrollView{
    return [[[MMPhotoManager sharedInstance] albums] count];
}

-(BOOL) prepareRowForReuse:(UIView*)aRow forScrollView:(MMCachedRowsScrollView*)scrollView{
    return [super prepareRowForReuse:aRow forScrollView:scrollView];
}

-(UIView*) updateRow:(UIView*)currentRow atIndex:(NSInteger)index forFrame:(CGRect)frame forScrollView:(MMCachedRowsScrollView*)scrollView{
    return [super updateRow:currentRow atIndex:index forFrame:frame forScrollView:scrollView];
}


#pragma mark - Description

-(NSString*) description{
    return @"Photo Albums";
}


@end
