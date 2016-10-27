//
//  MMScrapViewStateDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 10/1/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MMScrapViewState, MMScrapsInBezelContainerView;

@protocol MMScrapViewStateDelegate <NSObject>

- (void)didLoadScrapViewState:(MMScrapViewState*)state;

- (CGPoint)center;

- (CGFloat)rotation;

@end
