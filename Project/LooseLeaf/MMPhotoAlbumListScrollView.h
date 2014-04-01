//
//  MMPhotoAlbumListScrollView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/30/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMPhotoAlbumListScrollViewDataSource.h"

@interface MMPhotoAlbumListScrollView : UIScrollView<UIScrollViewDelegate>{
    __weak NSObject<MMPhotoAlbumListScrollViewDataSource>* dataSource;
}

@property (nonatomic, weak) NSObject<MMPhotoAlbumListScrollViewDataSource>* dataSource;
@property (readonly) CGFloat rowHeight;

- (id)initWithFrame:(CGRect)frame withRowHeight:(CGFloat)rowHeight andMargins:(CGFloat)topBottomMargin;

-(void) enumerateVisibleRowsWithBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block;

-(NSInteger) rowIndexForY:(CGFloat)y;

-(BOOL) rowIndexIsVisible:(NSInteger)index;

-(UIView*) rowAtIndex:(NSInteger) index;

-(void) refreshVisibleRows;

@end
