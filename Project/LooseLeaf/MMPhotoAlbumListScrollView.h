//
//  MMPhotoAlbumListScrollView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/30/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMPhotoAlbumListScrollView : UIScrollView

@property (readonly) CGFloat rowHeight;

- (id)initWithFrame:(CGRect)frame withRowHeight:(CGFloat)_rowHeight andMargins:(CGFloat)topBottomMargin;

-(NSInteger) rowIndexForY:(CGFloat)y;

-(BOOL) rowIndexIsVisible:(NSInteger)index;

@end
