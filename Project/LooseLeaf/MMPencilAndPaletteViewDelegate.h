//
//  MMPencilAndPaletteViewDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/9/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMSidebarButtonDelegate.h"

@protocol MMPencilAndPaletteViewDelegate <MMSidebarButtonDelegate>

-(void) penTapped:(UIButton*)button;

-(void) didChangeColorTo:(UIColor*)color;

@end
