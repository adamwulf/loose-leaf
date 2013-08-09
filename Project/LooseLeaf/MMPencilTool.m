//
//  MMPencilTool.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/9/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMPencilTool.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"

@implementation MMPencilTool{
    CGRect originalFrame;
    NSObject<MMPencilToolDelegate>* delegate;
    MMPencilButton* pencilButton;
    MMColorButton* blackButton;
    MMColorButton* blueButton;
    MMColorButton* redButton;
    MMColorButton* yellowButton;
    MMColorButton* greenButton;
    
    UIColor* color;
    
    BOOL isShowingColorOptions;
}

@synthesize color;

- (id)initWithButtonFrame:(CGRect)frame andScreenSize:(CGSize)totalSize
{
    originalFrame = frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame.size.width = totalSize.width;
    frame.size.height = totalSize.height;
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        color = [UIColor blackColor];
        
        // Initialization code
        self.layer.borderColor = [[UIColor redColor] CGColor];
        self.layer.borderWidth = 1;
        
        pencilButton = [[MMPencilButton alloc] initWithFrame:originalFrame];
        [pencilButton addTarget:self action:@selector(penTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:pencilButton];
        
        blackButton = [[MMColorButton alloc] initWithColor:[UIColor blackColor] andFrame:CGRectOffset(originalFrame, -kWidthOfSidebarButton + kWidthOfSidebarButtonBuffer, 0)];
        [blackButton addTarget:self action:@selector(colorTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:blackButton];

        blueButton = [[MMColorButton alloc] initWithColor:[UIColor blueColor] andFrame:CGRectOffset(originalFrame, -kWidthOfSidebarButton * 2 + kWidthOfSidebarButtonBuffer, 0)];
        [blueButton addTarget:self action:@selector(colorTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:blueButton];
    
        redButton = [[MMColorButton alloc] initWithColor:[UIColor redColor] andFrame:CGRectOffset(originalFrame, -kWidthOfSidebarButton * 3 + kWidthOfSidebarButtonBuffer, 0)];
        [redButton addTarget:self action:@selector(colorTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:redButton];
        
        yellowButton = [[MMColorButton alloc] initWithColor:[UIColor yellowColor] andFrame:CGRectOffset(originalFrame, -kWidthOfSidebarButton * 4 + kWidthOfSidebarButtonBuffer, 0)];
        [yellowButton addTarget:self action:@selector(colorTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:yellowButton];
        
        greenButton = [[MMColorButton alloc] initWithColor:[UIColor greenColor] andFrame:CGRectOffset(originalFrame, -kWidthOfSidebarButton * 5 + kWidthOfSidebarButtonBuffer, 0)];
        [greenButton addTarget:self action:@selector(colorTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:greenButton];
        
    }
    return self;
}


#pragma mark - Touch Events

//
// only return our button subviews,
// never ourself
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    for(UIView* subview in self.subviews){
        if([subview pointInside:[self convertPoint:point toView:subview] withEvent:event]){
            return subview;
        }
    }
    
    return nil;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    for(UIView* subview in self.subviews){
        if([subview pointInside:[self convertPoint:point toView:subview] withEvent:event]){
            return YES;
        }
    }
    return NO;
}

#pragma mark - MMSidebarButton

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


#pragma mark - Events

-(void) penTapped:(UIButton*)button{
    if(pencilButton.selected){
        if([self isShowingColors]){
            [self hideColors];
        }else{
            [self showColors];
        }
        NSLog(@"show colors");
    }else{
        [self.delegate penTapped:button];
    }
}


#pragma mark - Show Color Options

-(void) hideColors{
    if([self isShowingColors]){
        isShowingColorOptions = NO;
        [UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            blackButton.color = color;
            CGAffineTransform oldTransform = pencilButton.transform;
            pencilButton.transform = CGAffineTransformIdentity;
            pencilButton.frame = originalFrame;
            blackButton.frame = CGRectOffset(originalFrame, -kWidthOfSidebarButton + kWidthOfSidebarButtonBuffer, 0);
            blueButton.frame = CGRectOffset(originalFrame, -kWidthOfSidebarButton * 2 + kWidthOfSidebarButtonBuffer, 0);
            redButton.frame = CGRectOffset(originalFrame, -kWidthOfSidebarButton * 3 + kWidthOfSidebarButtonBuffer, 0);
            yellowButton.frame = CGRectOffset(originalFrame, -kWidthOfSidebarButton * 4 + kWidthOfSidebarButtonBuffer, 0);
            greenButton.frame = CGRectOffset(originalFrame, -kWidthOfSidebarButton * 5 + kWidthOfSidebarButtonBuffer, 0);
            pencilButton.transform = oldTransform;
        } completion:nil];
    }
}

-(void) showColors{
    if(![self isShowingColors]){
        isShowingColorOptions = YES;
        [UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            blackButton.color = [UIColor blackColor];
            
            CGAffineTransform oldTransform = pencilButton.transform;
            pencilButton.transform = CGAffineTransformIdentity;
            pencilButton.frame = CGRectOffset(originalFrame, kWidthOfSidebarButton*5, 0);
            blackButton.frame = CGRectOffset(CGRectOffset(originalFrame, -kWidthOfSidebarButton, 0), kWidthOfSidebarButton*5, 0);
            blueButton.frame = CGRectOffset(CGRectOffset(originalFrame, -kWidthOfSidebarButton * 2, 0), kWidthOfSidebarButton*5, 0);
            redButton.frame = CGRectOffset(CGRectOffset(originalFrame, -kWidthOfSidebarButton * 3, 0), kWidthOfSidebarButton*5, 0);
            yellowButton.frame = CGRectOffset(CGRectOffset(originalFrame, -kWidthOfSidebarButton * 4, 0), kWidthOfSidebarButton*5, 0);
            greenButton.frame = CGRectOffset(CGRectOffset(originalFrame, -kWidthOfSidebarButton * 5, 0), kWidthOfSidebarButton*5, 0);
            pencilButton.transform = oldTransform;
        } completion:nil];
    }
}


/**
 * return YES if we're currently showing the 
 * color button options, NO otherwise
 */
-(BOOL) isShowingColors{
    return isShowingColorOptions;
}


#pragma mark - Choose Color

-(void) colorTapped:(MMColorButton*)button{
    color = button.color;
    [self hideColors];
    [self.delegate didChangeColorTo:color];
}

@end
