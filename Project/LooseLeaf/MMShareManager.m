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
#import <JotUI/JotUI.h>

@implementation MMShareManager{
    // the document controller that we'll
    // use for drawing the buttons
    UIDocumentInteractionController* controller;
    NSMutableArray* allFoundCollectionViews;
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
    
    UIWindow* win = [[UIApplication sharedApplication] keyWindow];
    controller = [UIDocumentInteractionController interactionControllerWithURL:fileLocation];
    
    shouldListenToRegisterViews = YES;
    [controller presentOpenInMenuFromRect:CGRectZero inView:win animated:NO];
    shouldListenToRegisterViews = NO;
}

-(void) endSharing{
    CheckMainThread;
    
    if(controller){
        [controller dismissMenuAnimated:NO];
        controller = nil;
        [allFoundCollectionViews removeAllObjects];
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

#pragma mark - Number of Sharable Targets

-(NSUInteger) numberOfShareTargets{
    NSUInteger totalShareItems = 0;
    for(UICollectionView* cv in allFoundCollectionViews){
        totalShareItems += [cv numberOfItemsInSection:0];
    }
    return totalShareItems;
}

#pragma mark - Registering Popover and Collection Views

-(void) registerDismissView:(UIView*)dismissView{
    dismissView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.5];
    dismissView.alpha = .5;
    dismissView.hidden = YES;
}

-(void) addCollectionView:(UICollectionView*)view{
    @synchronized(self){
        [allFoundCollectionViews addObject:view];
    }
}

#pragma mark - Dealloc

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
