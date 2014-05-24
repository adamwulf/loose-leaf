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
@property (nonatomic, retain) UIImage* backingImage;

-(id) initWithImage:(UIImage*)img forScrapState:(MMScrapViewState*)scrapState;

#pragma mark Saving and Loading

-(void) loadBackgroundFromDisk;

-(void) saveBackgroundToDisk;

#pragma mark Duplication

-(MMScrapBackgroundView*) duplicateFor:(MMScrapViewState*)otherScrapState;

@end
