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
    NSObject<MMPencilToolDelegate>* delegate;
    MMPencilButton* pencilButton;
    MMColorButton* blackButton;
    MMColorButton* blueButton;
    MMColorButton* redButton;
    MMColorButton* yellowButton;
    MMColorButton* greenButton;
}

- (id)initWithButtonFrame:(CGRect)frame andScreenSize:(CGSize)totalSize
{
    originalFrame = frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame.size.width = totalSize.width;
    frame.size.height = totalSize.height;
    
    CGRect pencilButtonFrame = CGRectMake(originalFrame.origin.x, originalFrame.origin.y, originalFrame.size.width, originalFrame.size.height);
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.layer.borderColor = [[UIColor redColor] CGColor];
        self.layer.borderWidth = 1;
        
        pencilButton = [[MMPencilButton alloc] initWithFrame:pencilButtonFrame];
        [pencilButton addTarget:self action:@selector(penTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:pencilButton];
    }
    return self;
}


#pragma mark - Touch Events

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

#pragma MMSidebarButton

-(void) setTransform:(CGAffineTransform)transform{
    [pencilButton setTransform:transform];
}

-(NSObject<MMPencilToolDelegate>*)delegate{
    return delegate;
}

-(void) setDelegate:(NSObject<MMPencilToolDelegate> *)_delegate{
    delegate = _delegate;
    pencilButton.delegate = delegate;
}

-(void) setSelected:(BOOL)selected{
    [pencilButton setSelected:selected];
}

-(BOOL) selected{
    return pencilButton.selected;
}


#pragma Events

-(void) penTapped:(UIButton*)button{
    if(pencilButton.selected){
        NSLog(@"show colors");
    }else{
        [self.delegate penTapped:button];
    }
}

@end
