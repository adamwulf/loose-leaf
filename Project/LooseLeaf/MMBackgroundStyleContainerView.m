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

@implementation MMBackgroundStyleContainerView {
    UIView* sharingContentView;
    UIView* buttonView;
}

- (id)initWithFrame:(CGRect)frame forReferenceButtonFrame:(CGRect)buttonFrame animateFromLeft:(BOOL)fromLeft {
    if (self = [super initWithFrame:frame forReferenceButtonFrame:buttonFrame animateFromLeft:fromLeft]) {
        // Initialization code
        CGRect scrollViewBounds = self.bounds;
        scrollViewBounds.size.width = [slidingSidebarView contentBounds].origin.x + [slidingSidebarView contentBounds].size.width;
        sharingContentView = [[UIView alloc] initWithFrame:scrollViewBounds];
        
        CGRect contentBounds = [slidingSidebarView contentBounds];
        CGRect buttonBounds = scrollViewBounds;
        buttonBounds.origin.y = 0;
        buttonBounds.size.height = kHeightOfImportTypeButton + kHeightOfRotationTypeButton + 10;
        contentBounds.origin.y = buttonBounds.origin.y + buttonBounds.size.height;
        contentBounds.size.height -= buttonBounds.size.height;

        buttonView = [[UIView alloc] initWithFrame:contentBounds];
        [sharingContentView addSubview:buttonView];
        [slidingSidebarView addSubview:sharingContentView];

        // add page types to buttonView
    }
    return self;
}

- (CGFloat)buttonWidth {
    CGFloat buttonWidth = buttonView.bounds.size.width - kWidthOfSidebarButtonBuffer; // four buffers (3 between, and 1 on the right side)
    buttonWidth /= 4; // four buttons wide
    return buttonWidth;
}

- (CGRect)buttonBounds {
    CGFloat buttonWidth = [self buttonWidth];
    CGRect buttonBounds = buttonView.bounds;
    buttonBounds.origin.y = [UIApplication sharedApplication].statusBarFrame.size.height + kWidthOfSidebarButtonBuffer;
    buttonBounds.size.height = buttonWidth + kWidthOfSidebarButtonBuffer; // includes spacing buffer
    buttonBounds.origin.x += 2 * kWidthOfSidebarButtonBuffer;
    buttonBounds.size.width -= 2 * kWidthOfSidebarButtonBuffer;
    return buttonBounds;
}

#pragma mark - Rotation

- (CGFloat)sidebarButtonRotation {
    if ([MMRotationManager sharedInstance].lastBestOrientation == UIInterfaceOrientationPortrait) {
        return 0;
    } else if ([MMRotationManager sharedInstance].lastBestOrientation == UIInterfaceOrientationLandscapeLeft) {
        return -M_PI_2;
    } else if ([MMRotationManager sharedInstance].lastBestOrientation == UIInterfaceOrientationLandscapeRight) {
        return M_PI_2;
    } else {
        return M_PI;
    }
}

- (void)updateInterfaceTo:(UIInterfaceOrientation)orientation {
    CheckMainThread;
    [UIView animateWithDuration:.3 animations:^{
        CGAffineTransform rotationTransform = CGAffineTransformMakeRotation([self sidebarButtonRotation]);
        for (MMBounceButton* button in buttonView.subviews) {
            button.transform = rotationTransform;
        }
    }];
}

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
