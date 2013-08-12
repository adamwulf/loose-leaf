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
#import "UIColor+ColorWithHex.h"

@implementation MMPencilTool{
    CGRect originalFrame;
    NSObject<MMPencilToolDelegate>* delegate;
    MMPencilButton* pencilButton;
    MMColorButton* blackButton;
    MMColorButton* blueButton;
    MMColorButton* redButton;
    MMColorButton* yellowButton;
    MMColorButton* greenButton;

    MMColorButton* activeColorButton;

    UIColor* color;
    
    UIView* colorHolder;
    
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
        
        CGPoint pencilLocInContentHolder = CGPointMake(120, 20);
        
        colorHolder = [[UIView alloc] initWithFrame:CGRectMake(originalFrame.origin.x - pencilLocInContentHolder.x, originalFrame.origin.y - pencilLocInContentHolder.y, 200, 200)];
//        colorHolder.layer.borderColor = [UIColor redColor].CGColor;
//        colorHolder.layer.borderWidth = 1;
        [self setAnchorPoint:CGPointMake((pencilLocInContentHolder.x + originalFrame.size.width / 2) / colorHolder.frame.size.width,
                                         (pencilLocInContentHolder.y + originalFrame.size.height / 2) / colorHolder.frame.size.height) forView:colorHolder];
        [self addSubview:colorHolder];
        
        color = [UIColor blackColor];
        
        // Initialization code
        
        pencilButton = [[MMPencilButton alloc] initWithFrame:originalFrame];
        [pencilButton addTarget:self action:@selector(penTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:pencilButton];
        
        blackButton = [[MMColorButton alloc] initWithColor:[UIColor blackColor] andFrame:CGRectMake(pencilLocInContentHolder.x + kWidthOfSidebarButtonBuffer - kWidthOfSidebarButton, pencilLocInContentHolder.y, originalFrame.size.width, originalFrame.size.height)];
        [blackButton addTarget:self action:@selector(colorTapped:) forControlEvents:UIControlEventTouchUpInside];
        [colorHolder addSubview:blackButton];

        activeColorButton = [[MMColorButton alloc] initWithColor:[UIColor blackColor] andFrame:blackButton.originalFrame];
        [colorHolder addSubview:activeColorButton];

        blueButton = [[MMColorButton alloc] initWithColor:[UIColor colorWithHexString:@"3C7BFF"] andFrame:CGRectMake(pencilLocInContentHolder.x - kWidthOfSidebarButton * cosf(M_PI / 3), pencilLocInContentHolder.y + kWidthOfSidebarButton * sinf(M_PI / 3), originalFrame.size.width, originalFrame.size.height)];
        [blueButton addTarget:self action:@selector(colorTapped:) forControlEvents:UIControlEventTouchUpInside];
        [colorHolder addSubview:blueButton];
    
        redButton = [[MMColorButton alloc] initWithColor:[UIColor colorWithHexString:@"E8373E"] andFrame:CGRectMake(pencilLocInContentHolder.x - 1.8 * kWidthOfSidebarButton, pencilLocInContentHolder.y, originalFrame.size.width, originalFrame.size.height)];
        [redButton addTarget:self action:@selector(colorTapped:) forControlEvents:UIControlEventTouchUpInside];
        [colorHolder addSubview:redButton];
        
        yellowButton = [[MMColorButton alloc] initWithColor:[UIColor colorWithHexString:@"FFE230"] andFrame:CGRectMake(pencilLocInContentHolder.x - 1.8 * kWidthOfSidebarButton * cosf(M_PI / 6), pencilLocInContentHolder.y + 1.8 * kWidthOfSidebarButton * sinf(M_PI / 6), originalFrame.size.width, originalFrame.size.height)];
        [yellowButton addTarget:self action:@selector(colorTapped:) forControlEvents:UIControlEventTouchUpInside];
        [colorHolder addSubview:yellowButton];
        
        greenButton = [[MMColorButton alloc] initWithColor:[UIColor colorWithHexString:@"5EF52E"] andFrame:CGRectMake(pencilLocInContentHolder.x - 1.8 * kWidthOfSidebarButton * cosf(M_PI / 3), pencilLocInContentHolder.y + 1.8 * kWidthOfSidebarButton * sinf(M_PI / 3), originalFrame.size.width, originalFrame.size.height)];
        [greenButton addTarget:self action:@selector(colorTapped:) forControlEvents:UIControlEventTouchUpInside];
        [colorHolder addSubview:greenButton];
        
        
        // initialize alpha values
        blueButton.alpha = 0;
        greenButton.alpha = 0;
        activeColorButton.alpha = 1;
        activeColorButton.color = blackButton.color;
        blackButton.alpha = 0;
    }
    return self;
}


-(void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view
{
    CGPoint newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x, view.bounds.size.height * anchorPoint.y);
    CGPoint oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x, view.bounds.size.height * view.layer.anchorPoint.y);
    
    newPoint = CGPointApplyAffineTransform(newPoint, view.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform);
    
    CGPoint position = view.layer.position;
    
    position.x -= oldPoint.x;
    position.x += newPoint.x;
    
    position.y -= oldPoint.y;
    position.y += newPoint.y;
    
    view.layer.position = position;
    view.layer.anchorPoint = anchorPoint;
}



#pragma mark - Touch Events

//
// only return our button subviews,
// never ourself
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    for(UIView* subview in colorHolder.subviews){
        if([subview pointInside:[self convertPoint:point toView:subview] withEvent:event]){
            return subview;
        }
    }
    if([pencilButton pointInside:[self convertPoint:point toView:pencilButton] withEvent:event]){
        return pencilButton;
    }
    
    return nil;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    for(UIView* subview in colorHolder.subviews){
        if([subview pointInside:[self convertPoint:point toView:subview] withEvent:event]){
            return YES;
        }
    }
    if([pencilButton pointInside:[self convertPoint:point toView:pencilButton] withEvent:event]){
        return YES;
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
        [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
            activeColorButton.color = color;
            colorHolder.transform = CGAffineTransformIdentity;
            
            blackButton.frame = blackButton.originalFrame;
            blueButton.frame = blueButton.originalFrame;
            redButton.frame = redButton.originalFrame;
            yellowButton.frame = yellowButton.originalFrame;
            greenButton.frame = greenButton.originalFrame;

            blueButton.alpha = 0;
            greenButton.alpha = 0;
            blackButton.alpha = 0;
            activeColorButton.alpha = 1;
        } completion:nil];
    }
}

-(void) showColors{
    if(![self isShowingColors]){
        isShowingColorOptions = YES;
        [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
            blackButton.color = [UIColor blackColor];
            colorHolder.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI * 9 / 10);
            
            blackButton.frame = CGRectMake(120 - kWidthOfSidebarButton, 20, originalFrame.size.width, originalFrame.size.height);
            blueButton.frame = blueButton.originalFrame;
            redButton.frame = redButton.originalFrame;
            yellowButton.frame = yellowButton.originalFrame;
            greenButton.frame = greenButton.originalFrame;
            
            blueButton.alpha = 1;
            greenButton.alpha = 1;
            activeColorButton.alpha = 0;
            blackButton.alpha = 1;
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
