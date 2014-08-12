//
//  MMShareManager.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/10/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMShareManager.h"
#import "NSThread+BlockAdditions.h"
#import "UIView+Debug.h"
#import "MMShareView.h"
#import <JotUI/JotUI.h>

@implementation MMShareManager{
    // the document controller that we'll
    // use for drawing the buttons
    UIDocumentInteractionController* controller;
    NSMutableArray* allFoundCollectionViews;
    MMShareView* shareView;
}

static BOOL shouldListenToRegisterViews;
static MMShareManager* _instance = nil;

+(BOOL) shouldListenToRegisterViews{
    return shouldListenToRegisterViews;
}

-(NSArray*)allFoundCollectionViews{
    return [NSArray arrayWithArray:allFoundCollectionViews];
}

-(id) init{
    if(_instance) return _instance;
    if((self = [super init])){
        _instance = self;
        allFoundCollectionViews = [NSMutableArray array];
        
        UIWindow* win = [[UIApplication sharedApplication] keyWindow];
        shareView = [[MMShareView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        shareView.hidden = YES;
        [win.rootViewController.view addSubview:shareView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(endSharing)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];

    }
    return _instance;
}

+(MMShareManager*) sharedInstace{
    if(!_instance){
        _instance = [[MMShareManager alloc]init];
    }
    return _instance;
}

#pragma mark - Create and Dismiss the Document Controller

-(void) beginSharingWithURL:(NSURL*)fileLocation{
    CheckMainThread;
    
    controller = [UIDocumentInteractionController interactionControllerWithURL:fileLocation];
    
    shouldListenToRegisterViews = YES;
    [controller presentOpenInMenuFromRect:CGRectZero inView:shareView animated:NO];
    shouldListenToRegisterViews = NO;
    
    shareView.hidden = NO;

    for(int i=1;i<5;i++){
        [[NSThread mainThread] performBlock:^{
            [shareView setNeedsDisplay];
        } afterDelay:i];
    }
}

-(void) endSharing{
    CheckMainThread;
    
    if(controller){
        [controller dismissMenuAnimated:NO];
        controller = nil;
        [allFoundCollectionViews removeAllObjects];
        shareView.hidden = YES;
    }
    
    UIWindow* win = [[UIApplication sharedApplication] keyWindow];
    [[win rootViewController] dismissViewControllerAnimated:NO completion:nil];
    
    for (UIView* subview in win.subviews) {
        NSLog(@"still in window: %@", NSStringFromClass([subview class]));
        for (UIView* subview2 in subview.subviews) {
            NSLog(@"  still in subview: %@", NSStringFromClass([subview2 class]));
        }
    }
}

#pragma mark - Registering Popover and Collection Views

-(void) registerDismissView:(UIView*)dismissView{
    dismissView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.5];
    dismissView.alpha = .5;
    dismissView.hidden = YES;
    [shareView addSubview:dismissView];
}

-(void) addCollectionView:(UICollectionView*)view{
    @synchronized(self){
        [allFoundCollectionViews addObject:view];
        [shareView setNeedsDisplay];
    }
}

#pragma mark - Dealloc

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
