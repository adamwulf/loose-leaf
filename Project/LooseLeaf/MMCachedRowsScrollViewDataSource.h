//
//  MMPhotoAlbumListScrollViewDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 4/1/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MMCachedRowsScrollView;

@protocol MMCachedRowsScrollViewDataSource <NSObject>

-(NSInteger) numberOfRowsFor:(MMCachedRowsScrollView*)scrollView;

-(void) prepareRowForReuse:(UIView*)aRow forScrollView:(MMCachedRowsScrollView*)scrollView;

-(UIView*) updateRow:(UIView*)currentRow atIndex:(NSInteger)index forFrame:(CGRect)frame forScrollView:(MMCachedRowsScrollView*)scrollView;

@end
