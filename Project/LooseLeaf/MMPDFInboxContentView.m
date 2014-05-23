//
//  MMPDFInboxContentView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 5/23/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMPDFInboxContentView.h"
#import "MMPhotoManager.h"
#import "MMInboxManager.h"

@implementation MMPDFInboxContentView

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
        return [[[MMPhotoManager sharedInstace] albums] indexOfObject:album];
    }
    return -1;
}

-(MMPhotoAlbum*) albumAtIndex:(NSInteger)index{
    if(index < [[[MMPhotoManager sharedInstace] albums] count]){
        return [[[MMPhotoManager sharedInstace] albums] objectAtIndex:index];
    }
    return nil;
}

#pragma mark - MMCachedRowsScrollViewDataSource

-(NSInteger) numberOfRowsFor:(MMCachedRowsScrollView*)scrollView{
    if(scrollView == albumListScrollView){
        return [[[MMPhotoManager sharedInstace] albums] count];
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
    return @"PDF Inbox";
}
@end
