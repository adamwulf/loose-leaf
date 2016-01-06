//
//  MMPencilTool.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/9/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMColorButton.h"
#import "MMPaletteButton.h"
#import "MMPencilAndPaletteViewDelegate.h"

@interface MMPencilAndPaletteView : UIView

@property (nonatomic) CGFloat rotation;
@property (nonatomic) BOOL selected;
@property (readonly) MMPaletteButton* highlighterButton;
@property (readonly) MMPaletteButton* penButton;
@property (readonly) MMPaletteButton* pencilButton;
@property (nonatomic, weak) NSObject<MMPencilAndPaletteViewDelegate>* delegate;

- (id)initWithButtonFrame:(CGRect)frame andScreenSize:(CGSize)totalSize;

@end
