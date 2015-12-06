//
//  MMButtonToolbarView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 12/6/15.
//  Copyright © 2015 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMSidebarButton.h"
#import "MMPencilAndPaletteView.h"

struct SidebarButton{
    void* button;
    CGRect originalRect;
} SidebarButton;


@interface MMButtonToolbarView : UIView

@property (nonatomic, readonly) NSUInteger numberOfButtons;
@property (nonatomic, readonly) struct SidebarButton * buttons;

-(void) addButton:(UIView *)button extendFrame:(BOOL)extend;

-(void) addPencilTool:(MMPencilAndPaletteView*)pencilTool;

-(void) setButtonsVisible:(BOOL)visible;

@end
