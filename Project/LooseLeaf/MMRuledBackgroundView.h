//
//  MMRuledBackgroundView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/30/17.
//  Copyright © 2017 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MMScrapViewState, MMScrapBackgroundView;

@interface MMRuledBackgroundView : UIView

- (MMScrapBackgroundView*)stampBackgroundFor:(MMScrapViewState*)targetScrapState;

@end
