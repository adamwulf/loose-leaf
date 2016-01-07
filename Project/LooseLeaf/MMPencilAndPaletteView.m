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
#import "UIView+Animations.h"
#import "UIView+Debug.h"
#import "MMPencilButton.h"
#import "MMMarkerButton.h"
#import "MMHighlighterButton.h"

@implementation MMPencilAndPaletteView{
    CGRect originalFrame;
    NSObject<MMPencilAndPaletteViewDelegate>* delegate;
    MMPaletteButton* highlighterButton;
    MMPaletteButton* markerButton;
    MMPaletteButton* pencilButton;
    MMColorButton* blackButton;
    MMColorButton* blueButton;
    MMColorButton* redButton;
    MMColorButton* yellowButton;
    MMColorButton* greenButton;

    MMColorButton* activeColorButton;

    UIView* blackColorHolder;
    UIView* blueColorHolder;
    UIView* redColorHolder;
    UIView* yellowColorHolder;
    UIView* greenColorHolder;
    
    BOOL isShowingColorOptions;

    MMPaletteButton* activeButton;
    NSArray* allColors;
}

@synthesize highlighterButton;
@synthesize markerButton;
@synthesize pencilButton;

-(UIView*) newButtonHolderWithPencilLoc:(CGPoint)pencilLocInContentHolder{
    UIView* holder = [[UIView alloc] initWithFrame:CGRectMake(originalFrame.origin.x - pencilLocInContentHolder.x, originalFrame.origin.y - pencilLocInContentHolder.y, 200, 200)];
    [UIView setAnchorPoint:CGPointMake((pencilLocInContentHolder.x + originalFrame.size.width / 2) / holder.frame.size.width,
                                       (pencilLocInContentHolder.y + originalFrame.size.height / 2) / holder.frame.size.height) forView:holder];
    return holder;
}

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
        
        // Initialization code
        
        pencilButton = [[MMPencilButton alloc] initWithFrame:originalFrame];
        [pencilButton addTarget:self action:@selector(pencilTapped:) forControlEvents:UIControlEventTouchUpInside];
        pencilButton.tool = self;
        [self addSubview:pencilButton];
        
        markerButton = [[MMMarkerButton alloc] initWithFrame:originalFrame];
        [markerButton addTarget:self action:@selector(markerTapped:) forControlEvents:UIControlEventTouchUpInside];
        markerButton.tool = self;
        markerButton.center = CGPointApplyAffineTransform(pencilButton.center, CGAffineTransformMakeTranslation(-60, -kWidthOfSidebarButton));
        [self addSubview:markerButton];

        highlighterButton = [[MMHighlighterButton alloc] initWithFrame:originalFrame];
        [highlighterButton addTarget:self action:@selector(highlighterTapped:) forControlEvents:UIControlEventTouchUpInside];
        highlighterButton.tool = self;
        highlighterButton.center = CGPointApplyAffineTransform(pencilButton.center, CGAffineTransformMakeTranslation(-60, -2 * kWidthOfSidebarButton));
        [self addSubview:highlighterButton];

        blackColorHolder = [self newButtonHolderWithPencilLoc:pencilLocInContentHolder];
        [self addSubview:blackColorHolder];
        blackButton = [[MMColorButton alloc] initWithColor:[UIColor blackColor] andFrame:CGRectMake(pencilLocInContentHolder.x + kWidthOfSidebarButtonBuffer - kWidthOfSidebarButton, pencilLocInContentHolder.y, originalFrame.size.width, originalFrame.size.height)];
        [blackButton addTarget:self action:@selector(colorTapped:) forControlEvents:UIControlEventTouchUpInside];
        [blackColorHolder addSubview:blackButton];

        activeColorButton = [[MMColorButton alloc] initWithColor:[UIColor blackColor] andFrame:blackButton.originalFrame];
        [blackColorHolder addSubview:activeColorButton];

        blueColorHolder = [self newButtonHolderWithPencilLoc:pencilLocInContentHolder];
        [self addSubview:blueColorHolder];
        blueButton = [[MMColorButton alloc] initWithColor:[AVHexColor colorWithHexString:@"3C7BFF"] andFrame:CGRectMake(pencilLocInContentHolder.x - kWidthOfSidebarButton, pencilLocInContentHolder.y + kWidthOfSidebarButton, originalFrame.size.width, originalFrame.size.height)];
        [blueButton addTarget:self action:@selector(colorTapped:) forControlEvents:UIControlEventTouchUpInside];
        [blueColorHolder addSubview:blueButton];
    
        redColorHolder = [self newButtonHolderWithPencilLoc:pencilLocInContentHolder];
        [self addSubview:redColorHolder];
        redButton = [[MMColorButton alloc] initWithColor:[AVHexColor colorWithHexString:@"E8373E"] andFrame:CGRectMake(pencilLocInContentHolder.x - 2 * kWidthOfSidebarButton, pencilLocInContentHolder.y, originalFrame.size.width, originalFrame.size.height)];
        [redButton addTarget:self action:@selector(colorTapped:) forControlEvents:UIControlEventTouchUpInside];
        [redColorHolder addSubview:redButton];
        
        yellowColorHolder = [self newButtonHolderWithPencilLoc:pencilLocInContentHolder];
        [self addSubview:yellowColorHolder];
        yellowButton = [[MMColorButton alloc] initWithColor:[AVHexColor colorWithHexString:@"FFE230"] andFrame:CGRectMake(pencilLocInContentHolder.x - 2 * kWidthOfSidebarButton, pencilLocInContentHolder.y + kWidthOfSidebarButton, originalFrame.size.width, originalFrame.size.height)];
        [yellowButton addTarget:self action:@selector(colorTapped:) forControlEvents:UIControlEventTouchUpInside];
        [yellowColorHolder addSubview:yellowButton];
        
        greenColorHolder = [self newButtonHolderWithPencilLoc:pencilLocInContentHolder];
        [self addSubview:greenColorHolder];
        greenButton = [[MMColorButton alloc] initWithColor:[AVHexColor colorWithHexString:@"5EF52E"] andFrame:CGRectMake(pencilLocInContentHolder.x - kWidthOfSidebarButton, pencilLocInContentHolder.y + 2 * kWidthOfSidebarButton, originalFrame.size.width, originalFrame.size.height)];
        [greenButton addTarget:self action:@selector(colorTapped:) forControlEvents:UIControlEventTouchUpInside];
        [greenColorHolder addSubview:greenButton];
        
        
        // initialize alpha values
        blueButton.alpha = 0;
        greenButton.alpha = 0;
        activeColorButton.alpha = 1;
        blackButton.alpha = 0;

        activeButton = pencilButton;

        allColors = @[blackButton.color, redButton.color, blueButton.color, yellowButton.color, greenButton.color];

        NSInteger penColor = [[NSUserDefaults standardUserDefaults] integerForKey:@"penColor"];
        NSInteger pencilColor = [[NSUserDefaults standardUserDefaults] integerForKey:@"pencilColor"];
        NSInteger highlighterColor = [[NSUserDefaults standardUserDefaults] integerForKey:@"highlighterColor"];
        penColor = (penColor < 0) ? 0 : (penColor >= [allColors count]) ? 0 : penColor;
        pencilColor = (pencilColor < 0) ? 0 : (pencilColor >= [allColors count]) ? 0 : pencilColor;
        highlighterColor = (highlighterColor < 0) ? 0 : (highlighterColor >= [allColors count]) ? 0 : highlighterColor;

        markerButton.selectedColor = allColors[penColor];
        pencilButton.selectedColor = allColors[pencilColor];
        highlighterButton.selectedColor = allColors[highlighterColor];

        activeColorButton.color = activeButton.selectedColor;
    }
    return self;
}

-(CGFloat) rotation{
    return pencilButton.rotation;
}

-(void) setRotation:(CGFloat)_rotation{
    pencilButton.rotation = _rotation;
    markerButton.rotation = _rotation;
    highlighterButton.rotation = _rotation;
}

-(int) fullByteSize{
    return pencilButton.fullByteSize + markerButton.fullByteSize + highlighterButton.fullByteSize + blackButton.fullByteSize + blueButton.fullByteSize + redButton.fullByteSize + yellowButton.fullByteSize + greenButton.fullByteSize + activeColorButton.fullByteSize;
}

#pragma mark - Touch Events

//
// only return our button subviews,
// never ourself
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    for(UIView* subview in [NSArray arrayWithObjects:pencilButton, markerButton, highlighterButton, blackButton, blueButton, redButton, yellowButton, greenButton, nil]){
        if([subview pointInside:[self convertPoint:point toView:subview] withEvent:event]){
            return subview;
        }
    }
    return nil;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    for(UIView* subview in [NSArray arrayWithObjects:pencilButton, markerButton, highlighterButton, blackButton, blueButton, redButton, yellowButton, greenButton, nil]){
        if([subview pointInside:[self convertPoint:point toView:subview] withEvent:event]){
            return YES;
        }
    }
    return NO;
}

#pragma mark - MMSidebarButton

-(void) setTransform:(CGAffineTransform)transform{
    [pencilButton setTransform:transform];
    [markerButton setTransform:transform];
    [highlighterButton setTransform:transform];
}

-(NSObject<MMPencilAndPaletteViewDelegate>*)delegate{
    return delegate;
}

-(void) setDelegate:(NSObject<MMPencilAndPaletteViewDelegate> *)_delegate{
    delegate = _delegate;
    pencilButton.delegate = delegate;
    markerButton.delegate = delegate;
    highlighterButton.delegate = delegate;
    [self.delegate didChangeColorTo:activeButton.selectedColor];
}

-(void) setSelected:(BOOL)selected{
    [activeButton setSelected:selected];
    if(activeButton != markerButton){
        [markerButton setSelected:NO];
    }
    if(activeButton != pencilButton){
        [pencilButton setSelected:NO];
    }
    if(activeButton != highlighterButton){
        [highlighterButton setSelected:NO];
    }
}

-(BOOL) selected{
    return activeButton.selected;
}

-(void) setActiveButton:(MMPaletteButton*)button{
    activeButton = button;
    [self setSelected:YES];
    if(activeButton == pencilButton){
        [self.delegate pencilTapped:button];
    }else if(activeButton == markerButton){
        [self.delegate markerTapped:button];
    }else if(activeButton == highlighterButton){
        [self.delegate highlighterTapped:button];
    }
    [self.delegate didChangeColorTo:activeButton.selectedColor];

    if(!isShowingColorOptions){
        CGPoint originalCenter = CGPointMake(CGRectGetMidX(originalFrame), CGRectGetMidY(originalFrame));
        activeButton.center = originalCenter;
        if(markerButton != activeButton){
            markerButton.center = CGPointApplyAffineTransform(originalCenter, CGAffineTransformMakeTranslation(-60, -kWidthOfSidebarButton));
        }
        if(highlighterButton != activeButton){
            highlighterButton.center = CGPointApplyAffineTransform(originalCenter, CGAffineTransformMakeTranslation(-60, -2 * kWidthOfSidebarButton));
        }
        if(pencilButton != activeButton){
            pencilButton.center = CGPointApplyAffineTransform(originalCenter, CGAffineTransformMakeTranslation(-60, 0));
        }
        activeColorButton.color = activeButton.selectedColor;
    }
}


#pragma mark - Events

-(void) highlighterTapped:(UIButton*)button{
    if(highlighterButton.selected){
        if([self isShowingColors]){
            [self hideColors];
            [self.delegate colorMenuToggled];
        }else{
            [self showColors];
            [self.delegate colorMenuToggled];
        }
    }else{
        activeButton = highlighterButton;
        [self.delegate highlighterTapped:button];
        [self.delegate didChangeColorTo:activeButton.selectedColor];
        [self updateSelectedColorAndBounce:YES];
    }
}

-(void) pencilTapped:(UIButton*)button{
    if(pencilButton.selected){
        if([self isShowingColors]){
            [self hideColors];
            [self.delegate colorMenuToggled];
        }else{
            [self showColors];
            [self.delegate colorMenuToggled];
        }
    }else{
        activeButton = pencilButton;
        [self.delegate pencilTapped:button];
        [self.delegate didChangeColorTo:activeButton.selectedColor];
        [self updateSelectedColorAndBounce:YES];
    }
}

-(void) markerTapped:(UIButton*)button{
    if(markerButton.selected){
        if([self isShowingColors]){
            [self hideColors];
            [self.delegate colorMenuToggled];
        }else{
            [self showColors];
            [self.delegate colorMenuToggled];
        }
    }else{
        activeButton = markerButton;
        [self.delegate markerTapped:button];
        [self.delegate didChangeColorTo:activeButton.selectedColor];
        [self updateSelectedColorAndBounce:YES];
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
        [UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
            CGPoint originalCenter = CGPointMake(CGRectGetMidX(originalFrame), CGRectGetMidY(originalFrame));
            activeButton.center = originalCenter;
            if(markerButton != activeButton){
                markerButton.center = CGPointApplyAffineTransform(originalCenter, CGAffineTransformMakeTranslation(-60, -kWidthOfSidebarButton));
            }
            if(highlighterButton != activeButton){
                highlighterButton.center = CGPointApplyAffineTransform(originalCenter, CGAffineTransformMakeTranslation(-60, -2 * kWidthOfSidebarButton));
            }
            if(pencilButton != activeButton){
                pencilButton.center = CGPointApplyAffineTransform(originalCenter, CGAffineTransformMakeTranslation(-60, 0));
            }
        } completion:nil];

        [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
            activeColorButton.color = activeButton.selectedColor;
            blackColorHolder.transform = CGAffineTransformRotate(CGAffineTransformIdentity, .01);
            blueColorHolder.transform = CGAffineTransformRotate(CGAffineTransformIdentity, .01);
            greenColorHolder.transform = CGAffineTransformRotate(CGAffineTransformIdentity, .01);
            yellowColorHolder.transform = CGAffineTransformRotate(CGAffineTransformIdentity, .01);
            redColorHolder.transform = CGAffineTransformRotate(CGAffineTransformIdentity, .01);

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

-(void) updateSelectedColorAndBounce:(BOOL)shouldBounce{
    if([self isShowingColors]){
        blackButton.selected = NO;
        blueButton.selected = NO;
        redButton.selected = NO;
        yellowButton.selected = NO;
        greenButton.selected = NO;

        if(activeButton.selectedColor == blackButton.color){
            blackButton.selected = YES;
            if(shouldBounce) [blackButton bounce];
        }else if(activeButton.selectedColor == blueButton.color){
            blueButton.selected = YES;
            if(shouldBounce) [blueButton bounce];
        }else if(activeButton.selectedColor == redButton.color){
            redButton.selected = YES;
            if(shouldBounce) [redButton bounce];
        }else if(activeButton.selectedColor == yellowButton.color){
            yellowButton.selected = YES;
            if(shouldBounce) [yellowButton bounce];
        }else if(activeButton.selectedColor == greenButton.color){
            greenButton.selected = YES;
            if(shouldBounce) [greenButton bounce];
        }
    }
}

-(void) showColors{
    if(![self isShowingColors]){
        isShowingColorOptions = YES;
        [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
            blackButton.color = [UIColor blackColor];
            blackColorHolder.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI);
            
            blackButton.frame = CGRectMake(120 - kWidthOfSidebarButton, 20, originalFrame.size.width, originalFrame.size.height);
            blueButton.frame = blueButton.originalFrame;
            redButton.frame = redButton.originalFrame;
            yellowButton.frame = yellowButton.originalFrame;
            greenButton.frame = greenButton.originalFrame;

            [self updateSelectedColorAndBounce:NO];

            activeColorButton.alpha = 0;
            blackButton.alpha = 1;
        } completion:nil];


        CGPoint originalCenter = CGPointMake(CGRectGetMidX(originalFrame), CGRectGetMidY(originalFrame));
        [UIView animateWithDuration:(pencilButton == activeButton ? .3 : .22) delay:(pencilButton == activeButton ? 0 : .14) options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
            pencilButton.center = originalCenter;
        } completion:nil];
        [UIView animateWithDuration:(markerButton == activeButton ? .3 : .22) delay:(markerButton == activeButton ? 0 : .14) options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
            markerButton.center = CGPointApplyAffineTransform(originalCenter, CGAffineTransformMakeTranslation(0, -kWidthOfSidebarButton));
        } completion:nil];
        [UIView animateWithDuration:(highlighterButton == activeButton ? .3 : .19) delay:(highlighterButton == activeButton ? 0 : .2) options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
            highlighterButton.center = CGPointApplyAffineTransform(originalCenter, CGAffineTransformMakeTranslation(0, -2 * kWidthOfSidebarButton));
        } completion:nil];
        [UIView animateWithDuration:.1 delay:.15 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
            blueButton.alpha = 1;
            greenButton.alpha = 1;
        } completion:nil];
        [UIView animateWithDuration:.22 delay:.1 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
            blueColorHolder.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI);
        } completion:nil];
        [UIView animateWithDuration:.19 delay:.15 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
            greenColorHolder.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI);
        } completion:nil];
        [UIView animateWithDuration:.22 delay:.1 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
            yellowColorHolder.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI);
        } completion:nil];
        [UIView animateWithDuration:.25 delay:.05 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
            redColorHolder.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI);
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
    if([self isShowingColors]){
        blackButton.selected = NO;
        blueButton.selected = NO;
        redButton.selected = NO;
        yellowButton.selected = NO;
        greenButton.selected = NO;
        button.selected = YES;

        activeButton.selectedColor = button.color;
        
        [self.delegate didChangeColorTo:activeButton.selectedColor];

        if(activeButton == markerButton){
            [[NSUserDefaults standardUserDefaults] setObject:@([allColors indexOfObject:activeButton.selectedColor]) forKey:@"penColor"];
        }else if(activeButton == pencilButton){
            [[NSUserDefaults standardUserDefaults] setObject:@([allColors indexOfObject:activeButton.selectedColor]) forKey:@"pencilColor"];
        }else if(activeButton == highlighterButton){
            [[NSUserDefaults standardUserDefaults] setObject:@([allColors indexOfObject:activeButton.selectedColor]) forKey:@"highlighterColor"];
        }
    }
}

@end
