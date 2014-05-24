//
//  MMScrapBackgroundView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 5/23/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MMScrapViewState;

@interface MMScrapBackgroundView : UIView{
    CGFloat backgroundRotation;
    CGFloat backgroundScale;
    CGPoint backgroundOffset;
    BOOL backingViewHasChanged;
}

@property (nonatomic, readonly) UIImageView* backingContentView;
@property (nonatomic, assign) CGFloat backgroundRotation;
@property (nonatomic, assign) CGFloat backgroundScale;
@property (nonatomic, assign) CGPoint backgroundOffset;
@property (nonatomic, assign) BOOL backingViewHasChanged;

-(id) initWithImage:(UIImage*)img forScrapState:(MMScrapViewState*)scrapState;

-(void) updateBackingImageLocation;

-(void) setBackingImage:(UIImage*)img;

-(UIImage*) backingImage;

-(void) loadBackgroundFromDisk;

-(void) saveBackgroundToDisk;

@end
