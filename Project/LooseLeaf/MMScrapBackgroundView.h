//
//  MMScrapBackgroundView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 5/23/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMGenericBackgroundView.h"

@class MMScrapViewState;

@interface MMScrapBackgroundView : MMGenericBackgroundView

@property (nonatomic, readonly) UIImageView* backingContentView;
@property (nonatomic, assign) BOOL backingViewHasChanged;

+(int) totalBackgroundBytes;

-(id) initWithImage:(UIImage*)img forScrapState:(MMScrapViewState*)scrapState;

#pragma mark Saving and Loading

-(void) loadBackgroundFromDiskWithProperties:(NSDictionary*)properties;

-(NSDictionary*) saveBackgroundToDisk;

#pragma mark Duplication

-(MMScrapBackgroundView*) duplicateFor:(MMScrapViewState*)otherScrapState;

@end
