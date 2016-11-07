//
//  MMCollapsableStackView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/8/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMTutorialStackView.h"
#import "MMCollapsableStackViewDelegate.h"


@interface MMCollapsableStackView : MMTutorialStackView

@property (nonatomic, weak) NSObject<MMCollapsableStackViewDelegate>* stackDelegate;
@property (nonatomic, readonly) BOOL isPerfectlyAlignedIntoRow;

- (void)organizePagesIntoSingleRowAnimated:(BOOL)animated;
- (void)organizePagesIntoListAnimated:(BOOL)animated;
- (void)cancelPendingConfirmationsAndResetToRow;

@end
