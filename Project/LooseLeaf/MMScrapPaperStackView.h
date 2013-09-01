//
//  MMScrapPaperStackView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/29/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMEditablePaperStackView.h"
#import "MMScapBubbleContainerViewDelegate.h"

@interface MMScrapPaperStackView : MMEditablePaperStackView<MMPanAndPinchScrapGestureRecognizerDelegate,MMScapBubbleContainerViewDelegate>

@end
