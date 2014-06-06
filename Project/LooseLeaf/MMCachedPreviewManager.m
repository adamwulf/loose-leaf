//
//  MMCachedPreviewManager.m
//  LooseLeaf
//
//  Created by Adam Wulf on 6/6/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCachedPreviewManager.h"
#import <JotUI/JotUI.h>

@implementation MMCachedPreviewManager{
    NSMutableArray* arrayOfImageViews;
}

static MMCachedPreviewManager* _instance = nil;

-(id) init{
    if(_instance) return _instance;
    if((self = [super init])){
        _instance = self;
        arrayOfImageViews = [NSMutableArray array];
    }
    return _instance;
}

+(MMCachedPreviewManager*) sharedInstace{
    if(!_instance){
        _instance = [[MMCachedPreviewManager alloc]init];
    }
    return _instance;
}

-(UIImageView*) requestCachedImageViewForView:(UIView*)aView{
    if([arrayOfImageViews count]){
        UIImageView* view = [arrayOfImageViews lastObject];
        [arrayOfImageViews removeLastObject];
        return view;
    }
    UIImageView* cachedImgView = [[UIImageView alloc] initWithFrame:aView.bounds];
    cachedImgView.frame = aView.bounds;
    cachedImgView.contentMode = UIViewContentModeScaleAspectFill;
    cachedImgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    cachedImgView.clipsToBounds = YES;
    cachedImgView.opaque = YES;
    cachedImgView.backgroundColor = [UIColor whiteColor];
    return cachedImgView;
}

-(void) giveBackCachedImageView:(UIImageView*)imageView{
    [imageView removeFromSuperview];
    imageView.image = nil;
    if([arrayOfImageViews count] < 20){
        [arrayOfImageViews addObject:imageView];
    }else{
        [[JotTrashManager sharedInstance] addObjectToDealloc:imageView];
    }
}

@end
