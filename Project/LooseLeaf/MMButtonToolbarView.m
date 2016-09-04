//
//  MMButtonToolbarView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 12/6/15.
//  Copyright © 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMButtonToolbarView.h"
#import "Constants.h"

@implementation MMButtonToolbarView

-(instancetype) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        _numberOfButtons = 0;
        _buttons = calloc(sizeof(struct SidebarButton), 20);
    }
    return self;
}

#pragma mark - Public Methods

-(void) addButton:(UIView *)button extendFrame:(BOOL)extend{
    self.buttons[self.numberOfButtons].button = (__bridge void*)button;
    self.buttons[self.numberOfButtons].originalRect = button.frame;
    if(extend){
        self.buttons[self.numberOfButtons].originalRect = CGRectInset(button.frame, -(kWidthOfSidebar - kWidthOfSidebarButton)/2, 0) ;
    }

    _numberOfButtons++;

    [self addSubview:button];
}

-(void) addPencilTool:(MMPencilAndPaletteView*)pencilTool{
    self.buttons[self.numberOfButtons].button = (__bridge void*)pencilTool.markerButton;
    self.buttons[self.numberOfButtons].originalRect = pencilTool.markerButton.frame;
    _numberOfButtons++;

    self.buttons[self.numberOfButtons].button = (__bridge void*)pencilTool.pencilButton;
    self.buttons[self.numberOfButtons].originalRect = pencilTool.pencilButton.frame;
    _numberOfButtons++;

    self.buttons[self.numberOfButtons].button = (__bridge void*)pencilTool.highlighterButton;
    self.buttons[self.numberOfButtons].originalRect = pencilTool.highlighterButton.frame;
    _numberOfButtons++;

    [self addSubview:pencilTool];
}

-(void) setButtonsVisible:(BOOL)visible{
    for(int i=0;i<self.numberOfButtons;i++){
        [((__bridge UIButton*)self.buttons[i].button) setAlpha:visible];
    }
}

#pragma mark - Tap Handling

-(UIView*) hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    if([(__bridge UIButton*)self.buttons[0].button alpha]){
        UIView* sv = [super hitTest:point withEvent:event];
        if(sv != self){
            return sv;
        }
    }
    return nil;
}

-(BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    if([(__bridge UIButton*)self.buttons[0].button alpha]){
        for (UIView* subview in self.subviews) {
            if([subview pointInside:[subview convertPoint:point fromView:self] withEvent:event]){
                return YES;
            }
        }
    }
    return NO;
}

@end
