//
//  MMRoundedSquareViewDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/28/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MMRoundedSquareView;

@protocol MMRoundedSquareViewDelegate <NSObject>

- (void)didTapToCloseRoundedSquareView:(MMRoundedSquareView*)squareView;

@end
