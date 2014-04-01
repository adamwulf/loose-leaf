//
//  MMPhotoAlbumListScrollViewDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 4/1/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MMPhotoAlbumListScrollView;

@protocol MMPhotoAlbumListScrollViewDataSource <NSObject>

-(NSInteger) numberOfRowsFor:(MMPhotoAlbumListScrollView*)scrollView;

-(void) prepareRowForReuse:(UIView*)aRow forScrollView:(MMPhotoAlbumListScrollView*)scrollView;

-(UIView*) updateRow:(UIView*)currentRow atIndex:(NSInteger)index forFrame:(CGRect)frame;

@end
