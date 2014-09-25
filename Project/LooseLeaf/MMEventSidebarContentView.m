//
//  MMEventSidebarContentView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 4/9/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMEventSidebarContentView.h"
#import "MMPhotoManager.h"

@implementation MMEventSidebarContentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - Row Management

-(NSInteger) indexForAlbum:(MMPhotoAlbum*)album{
    if(album.type == ALAssetsGroupAlbum){
        return [[[MMPhotoManager sharedInstance] events] indexOfObject:album];
    }
    return -1;
}

-(MMPhotoAlbum*) albumAtIndex:(NSInteger)index{
    if(index < [[[MMPhotoManager sharedInstance] events] count]){
        return [[[MMPhotoManager sharedInstance] events] objectAtIndex:index];
    }
    return nil;
}

#pragma mark - MMCachedRowsScrollViewDataSource

-(NSInteger) numberOfRowsFor:(MMCachedRowsScrollView*)scrollView{
    if(scrollView == albumListScrollView){
        return [[[MMPhotoManager sharedInstance] events] count];
    }else{
        return ceilf(currentAlbum.numberOfPhotos / 2.0);
    }
}

-(BOOL) prepareRowForReuse:(UIView*)aRow forScrollView:(MMCachedRowsScrollView*)scrollView{
    return [super prepareRowForReuse:aRow forScrollView:scrollView];
}

-(UIView*) updateRow:(UIView*)currentRow atIndex:(NSInteger)index forFrame:(CGRect)frame forScrollView:(MMCachedRowsScrollView*)scrollView{
    return [super updateRow:currentRow atIndex:index forFrame:frame forScrollView:scrollView];
}

#pragma mark - Description

-(NSString*) description{
    return @"Photo Events";
}


@end
