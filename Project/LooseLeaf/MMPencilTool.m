//
//  MMPencilTool.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/9/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMPencilTool.h"
#import <QuartzCore/QuartzCore.h>

@implementation MMPencilTool{
    CGRect originalFrame;
    MMPencilButton* pencilButton;
    MMColorButton* blackButton;
    MMColorButton* blueButton;
    MMColorButton* redButton;
    MMColorButton* yellowButton;
    MMColorButton* greenButton;
}

- (id)initWithFrame:(CGRect)frame
{
    originalFrame = frame;
    frame.origin.x -= 100;
    frame.origin.y -= 100;
    frame.size.width += 200;
    frame.size.height += 200;
    
    CGRect pencilButtonFrame = CGRectMake(100, 100, originalFrame.size.width, originalFrame.size.height);
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.layer.borderColor = [[UIColor redColor] CGColor];
        self.layer.borderWidth = 1;
        
        pencilButton = [[MMPencilButton alloc] initWithFrame:pencilButtonFrame];
        [self addSubview:pencilButton];
    }
    return self;
}


//
// only return our button subviews,
// never ourself
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    if([pencilButton pointInside:[self convertPoint:point toView:pencilButton] withEvent:event]){
        return pencilButton;
    }
    
    return nil;
}


- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    return [pencilButton pointInside:[self convertPoint:point toView:pencilButton] withEvent:event];
}

-(void) setTransform:(CGAffineTransform)transform{
    [pencilButton setTransform:transform];
}

-(NSObject<MMSidebarButtonDelegate>*)delegate{
    return pencilButton.delegate;
}

-(void) setDelegate:(NSObject<MMSidebarButtonDelegate> *)delegate{
    pencilButton.delegate = delegate;
}

-(void) setSelected:(BOOL)selected{
    [pencilButton setSelected:selected];
}

-(BOOL) selected{
    return pencilButton.selected;
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents{
    [pencilButton addTarget:target action:action forControlEvents:controlEvents];
}


@end
