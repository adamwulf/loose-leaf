//
//  MMPencilTool.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/9/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMColorButton.h"
#import "MMPencilButton.h"
#import "MMPencilAndPaletteViewDelegate.h"

@interface MMPencilAndPaletteView : UIView

@property (nonatomic) BOOL selected;
@property (readonly) UIColor* color;
@property (nonatomic, weak) NSObject<MMPencilAndPaletteViewDelegate>* delegate;

- (id)initWithButtonFrame:(CGRect)frame andScreenSize:(CGSize)totalSize;

@end
