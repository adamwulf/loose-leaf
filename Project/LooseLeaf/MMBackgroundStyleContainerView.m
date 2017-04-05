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
#import "MMRuledTemplateView.h"
#import "MMEmptyTemplateView.h"
#import "Constants.h"
#import "MMBackgroundedPaperView.h"
#import "MMTodoListTemplateView.h"
#import "MMBoxNotesTemplateView.h"
#import "MMMusicTemplateView.h"
#import "MMCmGridTemplateView.h"
#import "MMInGridTemplateView.h"
#import "MMCmDotsTemplateView.h"

#define kNumberOfButtonColumns 2

@implementation MMBackgroundStyleContainerView {
    UIView* sharingContentView;
    NSArray<Class>* backgroundStyles;
}

@synthesize bgDelegate;

- (id)initWithFrame:(CGRect)frame forReferenceButtonFrame:(CGRect)buttonFrame animateFromLeft:(BOOL)fromLeft {
    if (self = [super initWithFrame:frame forReferenceButtonFrame:buttonFrame animateFromLeft:fromLeft]) {
        // Initialization code
        CGRect scrollViewBounds = self.bounds;
        scrollViewBounds.size.width = [slidingSidebarView contentBounds].origin.x + [slidingSidebarView contentBounds].size.width;
        sharingContentView = [[UIView alloc] initWithFrame:scrollViewBounds];
        
        
        [slidingSidebarView addSubview:sharingContentView];

        // add page types to buttonView
        backgroundStyles = [NSArray array];
        backgroundStyles = [backgroundStyles arrayByAddingObject:[MMEmptyTemplateView class]];
        backgroundStyles = [backgroundStyles arrayByAddingObject:[MMRuledTemplateView class]];
        backgroundStyles = [backgroundStyles arrayByAddingObject:[MMTodoListTemplateView class]];
        backgroundStyles = [backgroundStyles arrayByAddingObject:[MMBoxNotesTemplateView class]];
        backgroundStyles = [backgroundStyles arrayByAddingObject:[MMMusicTemplateView class]];
        backgroundStyles = [backgroundStyles arrayByAddingObject:[MMCmGridTemplateView class]];
        backgroundStyles = [backgroundStyles arrayByAddingObject:[MMInGridTemplateView class]];
        backgroundStyles = [backgroundStyles arrayByAddingObject:[MMCmDotsTemplateView class]];

        int buttonIndex = 0;
        CGFloat buttonWidth = [self buttonWidth];
        CGRect buttonBounds = [self buttonBounds];
        for (Class backgroundClass in backgroundStyles) {
            int column = (buttonIndex % kNumberOfButtonColumns);
            int row = floor(buttonIndex / (CGFloat)kNumberOfButtonColumns);
            CGRect frame = CGRectMake(2 * kWidthOfSidebarButtonBuffer + buttonBounds.origin.x + column * (buttonWidth + 2 * kWidthOfSidebarButtonBuffer),
                                      2 * kWidthOfSidebarButtonBuffer + buttonBounds.origin.y + row * ([self buttonHeight] + 2 * kWidthOfSidebarButtonBuffer),
                                      buttonWidth, [self buttonHeight]);
            MMPaperTemplateView* bgView = [[backgroundClass alloc] initWithFrame:frame
                                                                     andOriginalSize:[[UIScreen mainScreen] bounds].size
                                                                       andProperties:@{}];
            [bgView setUserInteractionEnabled:YES];
            bgView.layer.opaque = YES;
            bgView.layer.shadowOffset = CGSizeZero;
            bgView.layer.shadowRadius = 8;
            bgView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
            bgView.layer.shadowOpacity = 1;
            bgView.layer.anchorPoint = CGPointMake(.5, .5);
            bgView.layer.position = CGPointMake(.5, .5);
            [sharingContentView addSubview:bgView];
            
            UIButton* button = [[UIButton alloc] initWithFrame:frame];
            [button addTarget:self action:@selector(backgroundTypeTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            [sharingContentView addSubview:button];
            
            [bgView setFrame:frame];
            [button setFrame:frame];
            
            [bgView setTag:buttonIndex];
            [button setTag:buttonIndex];

            buttonIndex += 1;
        }
        
        NSString *defaultBackground = [MMBackgroundedPaperView defaultBackgroundClass];
        [self selectButtonForBackgroundClass:NSClassFromString(defaultBackground)];
    }
    return self;
}

- (CGFloat)buttonWidth {
    CGFloat buttonWidth = sharingContentView.bounds.size.width - 3 * kWidthOfSidebarButtonBuffer * (kNumberOfButtonColumns + 1);
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

-(void) selectButtonForBackgroundClass:(Class)backgroundClass{
    NSInteger index = backgroundClass ? [backgroundStyles indexOfObject:backgroundClass] : NSNotFound;
    for (UIView* styleView in [sharingContentView subviews]) {
        if(![styleView isKindOfClass:[UIButton class]]){
            if([styleView tag] == index){
                styleView.transform = CGAffineTransformIdentity;
            }else{
                styleView.transform = CGAffineTransformMakeScale(.7, .7);
            }
        }
    }
}

#pragma mark - Sidebar

-(void) show:(BOOL)animated{
    
    NSString* bgStyle = [[self bgDelegate] currentBackgroundStyleType];
    
    [self selectButtonForBackgroundClass:NSClassFromString(bgStyle)];
    
    [super show:animated];
}

#pragma mark - Action

-(IBAction)backgroundTypeTapped:(UIButton*)sender{
    [self selectButtonForBackgroundClass:backgroundStyles[sender.tag]];
    
    [[self bgDelegate] setCurrentBackgroundStyleType:NSStringFromClass(backgroundStyles[sender.tag])];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hide:YES onComplete:nil];
    });
}

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
