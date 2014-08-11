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

@implementation MMShareManager{
    NSMutableArray* allViews;
    MMShareView* shareView;
}

static MMShareManager* _instance = nil;

-(id) init{
    if(_instance) return _instance;
    if((self = [super init])){
        _instance = self;
        allViews = [NSMutableArray array];
        UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 10;
        layout.itemSize = CGSizeMake(100, 100);
        layout.sectionInset = UIEdgeInsetsZero;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        shareView = [[MMShareView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        UIWindow* win = [[UIApplication sharedApplication] keyWindow];
        [win addSubview:shareView];
    }
    return _instance;
}

+(MMShareManager*) sharedInstace{
    if(!_instance){
        _instance = [[MMShareManager alloc]init];
    }
    return _instance;
}

-(NSArray*)allViews{
    return [NSArray arrayWithArray:allViews];
}

-(void) registerDismissView:(UIView*)dismissView{
    dismissView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.5];
    dismissView.alpha = .5;
    dismissView.hidden = YES;
    [shareView addSubview:dismissView];
}

-(void) addCollectionView:(UICollectionView*)view{
    @synchronized(self){
        [allViews addObject:view];
        [shareView setNeedsDisplay];
        [[NSThread mainThread] performBlock:^{
            [shareView setNeedsDisplay];
        } afterDelay:5];
        
        [[NSThread mainThread] performBlock:^{
            [shareView setNeedsDisplay];
        } afterDelay:10];
    }
}

-(void) reset{
    UIWindow* win = [[UIApplication sharedApplication] keyWindow];
    [[win rootViewController] dismissViewControllerAnimated:NO completion:nil];

    [allViews removeAllObjects];
    
    for (UIView* subview in win.subviews) {
        NSLog(@"still in window: %@", NSStringFromClass([subview class]));
        for (UIView* subview2 in subview.subviews) {
            NSLog(@"  still in subview: %@", NSStringFromClass([subview2 class]));
        }
    }
}

@end
