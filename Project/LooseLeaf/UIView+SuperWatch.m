//
//  UIPopoverView+SuperWatch.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/10/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "UIView+SuperWatch.h"
#import <DrawKit-iOS/JRSwizzle.h>
#import "NSThread+BlockAdditions.h"
#import "MMShareManager.h"

static NSMutableArray* allDelegates;
static NSMutableArray* allDatasources;

@interface CollectDatasource : NSObject<UICollectionViewDataSource>

-(id) initWithOriginalDatasource:(NSObject<UICollectionViewDataSource>*)_origDatasource;

@end

@implementation CollectDatasource{
    NSObject<UICollectionViewDataSource>* origDatasource;
}

-(id) initWithOriginalDatasource:(NSObject<UICollectionViewDataSource>*)_origDatasource{
    if(!allDatasources){
        allDatasources = [NSMutableArray array];
    }
    if(self = [super init]){
        origDatasource = _origDatasource;
    }
    return self;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [origDatasource collectionView:collectionView numberOfItemsInSection:section];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell* cvc = [origDatasource collectionView:collectionView cellForItemAtIndexPath:indexPath];
    [[NSThread mainThread] performBlock:^{
        [cvc layoutSubviews];
    }afterDelay:1];
//    [cvc layoutSubviews];
    return cvc;
}

@end


@interface CollectDelegate : NSObject<UICollectionViewDelegate>

-(id) initWithOriginalDelegate:(NSObject<UICollectionViewDelegate>*)_origDelegate;

@end

@implementation CollectDelegate{
    NSObject<UICollectionViewDelegate>* origDelegate;
}

-(id) initWithOriginalDelegate:(NSObject<UICollectionViewDelegate>*)_origDelegate{
    if(!allDelegates){
        allDelegates = [NSMutableArray array];
    }
    if(self = [super init]){
        origDelegate = _origDelegate;
    }
    return self;
}


- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    if([origDelegate respondsToSelector:@selector(collectionView:shouldHighlightItemAtIndexPath:)]){
        return [origDelegate collectionView:collectionView shouldHighlightItemAtIndexPath:indexPath];
    }
   return YES;
}


- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    if([origDelegate respondsToSelector:@selector(collectionView:didHighlightItemAtIndexPath:)]){
        return [origDelegate collectionView:collectionView didHighlightItemAtIndexPath:indexPath];
    }
}


- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    if([origDelegate respondsToSelector:@selector(collectionView:didUnhighlightItemAtIndexPath:)]){
        return [origDelegate collectionView:collectionView didUnhighlightItemAtIndexPath:indexPath];
    }
}


- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if([origDelegate respondsToSelector:@selector(collectionView:shouldSelectItemAtIndexPath:)]){
        return [origDelegate collectionView:collectionView shouldSelectItemAtIndexPath:indexPath];
    }
    return YES;
}

// called when the user taps on an already-selected item in multi-select mode
- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    if([origDelegate respondsToSelector:@selector(collectionView:shouldDeselectItemAtIndexPath:)]){
        return [origDelegate collectionView:collectionView shouldDeselectItemAtIndexPath:indexPath];
    }
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if([origDelegate respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]){
        return [origDelegate collectionView:collectionView didSelectItemAtIndexPath:indexPath];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    if([origDelegate respondsToSelector:@selector(collectionView:didDeselectItemAtIndexPath:)]){
        return [origDelegate collectionView:collectionView didDeselectItemAtIndexPath:indexPath];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    if([origDelegate respondsToSelector:@selector(collectionView:didEndDisplayingCell:forItemAtIndexPath:)]){
        return [origDelegate collectionView:collectionView didEndDisplayingCell:cell forItemAtIndexPath:indexPath];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath{
    if([origDelegate respondsToSelector:@selector(collectionView:didEndDisplayingSupplementaryView:forElementOfKind:atIndexPath:)]){
        return [origDelegate collectionView:collectionView didEndDisplayingSupplementaryView:view forElementOfKind:elementKind atIndexPath:indexPath];
    }
}

// These methods provide support for copy/paste actions on cells.
// All three should be implemented if any are.
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath{
    if([origDelegate respondsToSelector:@selector(collectionView:shouldShowMenuForItemAtIndexPath:)]){
        return [origDelegate collectionView:collectionView shouldShowMenuForItemAtIndexPath:indexPath];
    }
    return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
    if([origDelegate respondsToSelector:@selector(collectionView:canPerformAction:forItemAtIndexPath:withSender:)]){
        return [origDelegate collectionView:collectionView canPerformAction:action forItemAtIndexPath:indexPath withSender:sender];
    }
    return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
    return [origDelegate collectionView:collectionView performAction:action forItemAtIndexPath:indexPath withSender:sender];
}

// support for custom transition layout
- (UICollectionViewTransitionLayout *)collectionView:(UICollectionView *)collectionView transitionLayoutForOldLayout:(UICollectionViewLayout *)fromLayout newLayout:(UICollectionViewLayout *)toLayout{
    if([origDelegate respondsToSelector:@selector(collectionView:transitionLayoutForOldLayout:newLayout:)]){
        return [origDelegate collectionView:collectionView transitionLayoutForOldLayout:fromLayout newLayout:toLayout];
    }
    return [[UICollectionViewTransitionLayout alloc] initWithCurrentLayout:fromLayout nextLayout:toLayout];
}

@end




@implementation UIView (SuperWatch)


-(void) swizzle_addSubview:(UIView *)view{
    if([self isKindOfClass:[UIWindow class]]){
        [self swizzle_addSubview:view];
        return;
    }
    NSString* classOfView = NSStringFromClass([view class]);
    
    BOOL ok = YES;
    
    if([view isKindOfClass:[UICollectionView class]]){
        ok = NO;
        [[MMShareManager sharedInstace] addCollectionView:(UICollectionView*)view];
    }else if([classOfView rangeOfString:@"DimmingView"].location != NSNotFound){
        ok = NO;
        [[MMShareManager sharedInstace] registerDismissView:view];
    }else if([classOfView rangeOfString:@"PopoverView"].location != NSNotFound){
        ok = NO;
    }else{
        for(UIView* subview in view.subviews){
            NSString* classOfView = NSStringFromClass([subview class]);
            if([classOfView rangeOfString:@"PopoverView"].location != NSNotFound){
                ok = NO;
            }
        }
    }
    
    [self swizzle_addSubview:view];
//    if(!ok){
//        [self iterateOverView:view withDepth:0];
//    }
}
//
-(void) iterateOverView:(UIView*)v withDepth:(int)depth{
    NSString* prefix = @"";
    for(int i=0;i<depth;i++){
        prefix = [prefix stringByAppendingString:@" "];
    }
    
    NSLog(@"%@[%@]%@",prefix, NSStringFromClass([v class]), [v description]);
    
    for (UIView* subview in v.subviews) {
        [self iterateOverView:subview withDepth:depth+1];
    }
    
    if([v isKindOfClass:[UICollectionView class]]){
        
        UICollectionView* cv = (UICollectionView*)v;
        
        NSLog(@"found collection view");
        NSLog(@"delegate: %@",cv.delegate);
        NSLog(@"datasource: %@",cv.dataSource);
        
//        [allDelegates addObject:[[CollectDelegate alloc] initWithOriginalDelegate:cv.delegate]];
//        cv.delegate = [allDelegates lastObject];
        
//        [allDatasources addObject:[[CollectDatasource alloc] initWithOriginalDatasource:cv.dataSource]];
//        cv.dataSource = [allDatasources lastObject];
        [[MMShareManager sharedInstace] addCollectionView:cv];
    }
}

+(void)load{
    @autoreleasepool {
        NSError *error = nil;
        [UIView jr_swizzleMethod:@selector(addSubview:)
                            withMethod:@selector(swizzle_addSubview:)
                                      error:&error];
    }
}



@end
