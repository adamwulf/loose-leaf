//
//  MMPencilTool.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/9/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMPencilAndPaletteView.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"
#import "AVHexColor.h"

@implementation MMPencilAndPaletteView{
    CGRect originalFrame;
    NSObject<MMPencilAndPaletteViewDelegate>* delegate;
    MMPencilButton* pencilButton;
    MMColorButton* blackButton;
    MMColorButton* blueButton;
    MMColorButton* redButton;
    MMColorButton* yellowButton;
    MMColorButton* greenButton;

    MMColorButton* activeColorButton;

    UIColor* color;
    
    UIView* blackColorHolder;
    UIView* blueColorHolder;
    UIView* redColorHolder;
    UIView* yellowColorHolder;
    UIView* greenColorHolder;
    
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
        
        color = [UIColor blackColor];
        
        // Initialization code
        
        pencilButton = [[MMPencilButton alloc] initWithFrame:originalFrame];
        [pencilButton addTarget:self action:@selector(penTapped:) forControlEvents:UIControlEventTouchUpInside];
        pencilButton.tool = self;
        [self addSubview:pencilButton];
        
        blackColorHolder = [[UIView alloc] initWithFrame:CGRectMake(originalFrame.origin.x - pencilLocInContentHolder.x, originalFrame.origin.y - pencilLocInContentHolder.y, 200, 200)];
        [self setAnchorPoint:CGPointMake((pencilLocInContentHolder.x + originalFrame.size.width / 2) / blackColorHolder.frame.size.width,
                                         (pencilLocInContentHolder.y + originalFrame.size.height / 2) / blackColorHolder.frame.size.height) forView:blackColorHolder];
        [self addSubview:blackColorHolder];
        blackButton = [[MMColorButton alloc] initWithColor:[UIColor blackColor] andFrame:CGRectMake(pencilLocInContentHolder.x + kWidthOfSidebarButtonBuffer - kWidthOfSidebarButton, pencilLocInContentHolder.y, originalFrame.size.width, originalFrame.size.height)];
        [blackButton addTarget:self action:@selector(colorTapped:) forControlEvents:UIControlEventTouchUpInside];
        [blackColorHolder addSubview:blackButton];

        activeColorButton = [[MMColorButton alloc] initWithColor:[UIColor blackColor] andFrame:blackButton.originalFrame];
        [blackColorHolder addSubview:activeColorButton];

        blueColorHolder = [[UIView alloc] initWithFrame:CGRectMake(originalFrame.origin.x - pencilLocInContentHolder.x, originalFrame.origin.y - pencilLocInContentHolder.y, 200, 200)];
        [self setAnchorPoint:CGPointMake((pencilLocInContentHolder.x + originalFrame.size.width / 2) / blackColorHolder.frame.size.width,
                                         (pencilLocInContentHolder.y + originalFrame.size.height / 2) / blackColorHolder.frame.size.height) forView:blueColorHolder];
        [self addSubview:blueColorHolder];
        blueButton = [[MMColorButton alloc] initWithColor:[AVHexColor colorWithHexString:@"3C7BFF"] andFrame:CGRectMake(pencilLocInContentHolder.x - kWidthOfSidebarButton * cosf(M_PI / 3), pencilLocInContentHolder.y + kWidthOfSidebarButton * sinf(M_PI / 3), originalFrame.size.width, originalFrame.size.height)];
        [blueButton addTarget:self action:@selector(colorTapped:) forControlEvents:UIControlEventTouchUpInside];
        [blueColorHolder addSubview:blueButton];
    
        redColorHolder = [[UIView alloc] initWithFrame:CGRectMake(originalFrame.origin.x - pencilLocInContentHolder.x, originalFrame.origin.y - pencilLocInContentHolder.y, 200, 200)];
        [self setAnchorPoint:CGPointMake((pencilLocInContentHolder.x + originalFrame.size.width / 2) / blackColorHolder.frame.size.width,
                                         (pencilLocInContentHolder.y + originalFrame.size.height / 2) / blackColorHolder.frame.size.height) forView:redColorHolder];
        [self addSubview:redColorHolder];
        redButton = [[MMColorButton alloc] initWithColor:[AVHexColor colorWithHexString:@"E8373E"] andFrame:CGRectMake(pencilLocInContentHolder.x - 2 * kWidthOfSidebarButton, pencilLocInContentHolder.y, originalFrame.size.width, originalFrame.size.height)];
        [redButton addTarget:self action:@selector(colorTapped:) forControlEvents:UIControlEventTouchUpInside];
        [redColorHolder addSubview:redButton];
        
        yellowColorHolder = [[UIView alloc] initWithFrame:CGRectMake(originalFrame.origin.x - pencilLocInContentHolder.x, originalFrame.origin.y - pencilLocInContentHolder.y, 200, 200)];
        [self setAnchorPoint:CGPointMake((pencilLocInContentHolder.x + originalFrame.size.width / 2) / blackColorHolder.frame.size.width,
                                         (pencilLocInContentHolder.y + originalFrame.size.height / 2) / blackColorHolder.frame.size.height) forView:yellowColorHolder];
        [self addSubview:yellowColorHolder];
        yellowButton = [[MMColorButton alloc] initWithColor:[AVHexColor colorWithHexString:@"FFE230"] andFrame:CGRectMake(pencilLocInContentHolder.x - 1.8 * kWidthOfSidebarButton * cosf(M_PI / 6), pencilLocInContentHolder.y + 1.8 * kWidthOfSidebarButton * sinf(M_PI / 6), originalFrame.size.width, originalFrame.size.height)];
        [yellowButton addTarget:self action:@selector(colorTapped:) forControlEvents:UIControlEventTouchUpInside];
        [yellowColorHolder addSubview:yellowButton];
        
        greenColorHolder = [[UIView alloc] initWithFrame:CGRectMake(originalFrame.origin.x - pencilLocInContentHolder.x, originalFrame.origin.y - pencilLocInContentHolder.y, 200, 200)];
        [self setAnchorPoint:CGPointMake((pencilLocInContentHolder.x + originalFrame.size.width / 2) / blackColorHolder.frame.size.width,
                                         (pencilLocInContentHolder.y + originalFrame.size.height / 2) / blackColorHolder.frame.size.height) forView:greenColorHolder];
        [self addSubview:greenColorHolder];
        greenButton = [[MMColorButton alloc] initWithColor:[AVHexColor colorWithHexString:@"5EF52E"] andFrame:CGRectMake(pencilLocInContentHolder.x - 2 * kWidthOfSidebarButton * cosf(M_PI / 3), pencilLocInContentHolder.y + 2 * kWidthOfSidebarButton * sinf(M_PI / 3), originalFrame.size.width, originalFrame.size.height)];
        [greenButton addTarget:self action:@selector(colorTapped:) forControlEvents:UIControlEventTouchUpInside];
        [greenColorHolder addSubview:greenButton];
        
        
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
    for(UIView* subview in [NSArray arrayWithObjects:pencilButton, blackButton, blueButton, redButton, yellowButton, greenButton, nil]){
        if([subview pointInside:[self convertPoint:point toView:subview] withEvent:event]){
            return subview;
        }
    }
    return nil;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    for(UIView* subview in [NSArray arrayWithObjects:pencilButton, blackButton, blueButton, redButton, yellowButton, greenButton, nil]){
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

-(NSObject<MMPencilAndPaletteViewDelegate>*)delegate{
    return delegate;
}

-(void) setDelegate:(NSObject<MMPencilAndPaletteViewDelegate> *)_delegate{
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
            [self.delegate colorMenuToggled];
        }else{
            [self showColors];
            [self.delegate colorMenuToggled];
        }
    }else{
        [self.delegate penTapped:button];
    }
}


#pragma mark - Show Color Options

-(void) hideColors{
    if([self isShowingColors]){
        blackButton.selected = NO;
        blueButton.selected = NO;
        redButton.selected = NO;
        yellowButton.selected = NO;
        greenButton.selected = NO;

        isShowingColorOptions = NO;
        [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
            activeColorButton.color = color;
            blackColorHolder.transform = CGAffineTransformIdentity;
            blueColorHolder.transform = CGAffineTransformIdentity;
            greenColorHolder.transform = CGAffineTransformIdentity;
            yellowColorHolder.transform = CGAffineTransformIdentity;
            redColorHolder.transform = CGAffineTransformIdentity;

            blackButton.frame = blackButton.originalFrame;
            blueButton.frame = blueButton.originalFrame;
            redButton.frame = redButton.originalFrame;
            yellowButton.frame = yellowButton.originalFrame;
            greenButton.frame = greenButton.originalFrame;

            blackButton.alpha = 0;
            activeColorButton.alpha = 1;
        } completion:nil];
    }
    [UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
        greenButton.alpha = 0;
        blueButton.alpha = 0;
    } completion:nil];
}

-(void) showColors{
    if(![self isShowingColors]){
        isShowingColorOptions = YES;
        [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
            blackButton.color = [UIColor blackColor];
            blackColorHolder.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI * 9 / 10);
            
            blackButton.frame = CGRectMake(120 - kWidthOfSidebarButton, 20, originalFrame.size.width, originalFrame.size.height);
            blueButton.frame = blueButton.originalFrame;
            redButton.frame = redButton.originalFrame;
            yellowButton.frame = yellowButton.originalFrame;
            greenButton.frame = greenButton.originalFrame;
            
            if(activeColorButton.color == blackButton.color){
                blackButton.selected = YES;
            }else if(activeColorButton.color == blueButton.color){
                blueButton.selected = YES;
            }else if(activeColorButton.color == redButton.color){
                redButton.selected = YES;
            }else if(activeColorButton.color == yellowButton.color){
                yellowButton.selected = YES;
            }else if(activeColorButton.color == greenButton.color){
                greenButton.selected = YES;
            }
            
            activeColorButton.alpha = 0;
            blackButton.alpha = 1;
        } completion:nil];
        [UIView animateWithDuration:.1 delay:.15 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
            blueButton.alpha = 1;
            greenButton.alpha = 1;
        } completion:nil];
        [UIView animateWithDuration:.22 delay:.1 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
            blueColorHolder.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI * 9 / 10);
        } completion:nil];
        [UIView animateWithDuration:.19 delay:.15 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
            greenColorHolder.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI * 9 / 10);
        } completion:nil];
        [UIView animateWithDuration:.22 delay:.1 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
            yellowColorHolder.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI * 9 / 10);
        } completion:nil];
        [UIView animateWithDuration:.25 delay:.05 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
            redColorHolder.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI * 9 / 10);
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
    
    blackButton.selected = NO;
    blueButton.selected = NO;
    redButton.selected = NO;
    yellowButton.selected = NO;
    greenButton.selected = NO;
    button.selected = YES;
    
    color = button.color;
    [self.delegate didChangeColorTo:color];
    [pencilButton setNeedsDisplay];
}

@end
