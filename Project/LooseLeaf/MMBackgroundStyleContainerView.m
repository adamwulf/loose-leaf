//
//  MMBackgroundStyleContainerView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 4/3/17.
//  Copyright © 2017 Milestone Made, LLC. All rights reserved.
//

#import "MMBackgroundStyleContainerView.h"
#import "MMImageViewButton.h"
#import "NSThread+BlockAdditions.h"
#import "MMRotationManager.h"
#import "Constants.h"
#import "UIView+Debug.h"
#import <JotUI/JotUI.h>
#import "MMRuledBackgroundView.h"
#import "MMEmptyBackgroundView.h"
#import "Constants.h"

#define kNumberOfButtonColumns 2

@implementation MMBackgroundStyleContainerView {
    UIView* sharingContentView;
}

- (id)initWithFrame:(CGRect)frame forReferenceButtonFrame:(CGRect)buttonFrame animateFromLeft:(BOOL)fromLeft {
    if (self = [super initWithFrame:frame forReferenceButtonFrame:buttonFrame animateFromLeft:fromLeft]) {
        // Initialization code
        CGRect scrollViewBounds = self.bounds;
        scrollViewBounds.size.width = [slidingSidebarView contentBounds].origin.x + [slidingSidebarView contentBounds].size.width;
        sharingContentView = [[UIView alloc] initWithFrame:scrollViewBounds];
        
        [slidingSidebarView addSubview:sharingContentView];

        // add page types to buttonView
        NSArray<Class>* backgroundStyles = [NSArray array];
        backgroundStyles = [backgroundStyles arrayByAddingObject:[MMEmptyBackgroundView class]];
        backgroundStyles = [backgroundStyles arrayByAddingObject:[MMRuledBackgroundView class]];
        backgroundStyles = [backgroundStyles arrayByAddingObject:[MMRuledBackgroundView class]];
        backgroundStyles = [backgroundStyles arrayByAddingObject:[MMEmptyBackgroundView class]];
        
        int buttonIndex = 0;
        CGFloat buttonWidth = [self buttonWidth];
        CGRect buttonBounds = [self buttonBounds];
        for (Class backgroundClass in backgroundStyles) {
            MMBackgroundPatternView* button = [[backgroundClass alloc] initWithFrame:CGRectMake(0,0,[self buttonWidth], [self buttonHeight])
                                                                     andOriginalSize:[[UIScreen mainScreen] bounds].size
                                                                       andProperties:@{}];
            
            int column = (buttonIndex % kNumberOfButtonColumns);
            int row = floor(buttonIndex / (CGFloat)kNumberOfButtonColumns);
            button.frame = CGRectMake(buttonBounds.origin.x + column * (buttonWidth + kWidthOfSidebarButtonBuffer),
                                      buttonBounds.origin.y + row * ([self buttonHeight] + kWidthOfSidebarButtonBuffer),
                                      buttonWidth, [self buttonHeight]);
            
            [sharingContentView insertSubview:button atIndex:buttonIndex];
            
            buttonIndex += 1;
        }
    }
    return self;
}

- (CGFloat)buttonWidth {
    CGFloat buttonWidth = sharingContentView.bounds.size.width - kWidthOfSidebarButtonBuffer * (kNumberOfButtonColumns + 1);
    buttonWidth /= kNumberOfButtonColumns; // two buttons wide
    return buttonWidth;
}

- (CGFloat)buttonHeight {
    CGSize size = [[UIScreen mainScreen] bounds].size;
    
    return size.height * [self buttonWidth] / size.width;
}

- (CGRect)buttonBounds {
    CGFloat buttonWidth = [self buttonWidth];
    CGRect buttonBounds = sharingContentView.bounds;
    buttonBounds.origin.y = [UIApplication sharedApplication].statusBarFrame.size.height + kWidthOfSidebarButtonBuffer;
    buttonBounds.size.height = buttonWidth + kWidthOfSidebarButtonBuffer; // includes spacing buffer
    buttonBounds.origin.x += 2 * kWidthOfSidebarButtonBuffer;
    buttonBounds.size.width -= 2 * kWidthOfSidebarButtonBuffer;
    return buttonBounds;
}

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
