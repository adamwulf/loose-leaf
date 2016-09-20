//
//  MMRoundedSquareView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/28/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMRoundedSquareViewDelegate.h"


@interface MMRoundedSquareView : UIView

@property (nonatomic, readonly) UIView* rotateableSquareView;
@property (nonatomic, readonly) UIView* maskedScrollContainer;
@property (nonatomic, readonly) CGFloat boxSize;
@property (nonatomic, weak) NSObject<MMRoundedSquareViewDelegate>* delegate;
@property (nonatomic, assign) BOOL allowTappingOutsideToClose;

@end
