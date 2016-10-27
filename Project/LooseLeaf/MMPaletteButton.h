//
//  MMPaletteButton.h
//  LooseLeaf
//
//  Created by Adam Wulf on 1/6/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMSidebarButton.h"

@class MMPencilAndPaletteView;


@interface MMPaletteButton : MMSidebarButton

@property (nonatomic, weak) MMPencilAndPaletteView* tool;
@property (nonatomic, strong) UIColor* selectedColor;

@end
