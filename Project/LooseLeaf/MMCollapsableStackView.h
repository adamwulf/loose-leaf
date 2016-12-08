//
//  MMCollapsableStackView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/8/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMTutorialStackView.h"
#import "MMCollapsableStackViewDelegate.h"
#import "MMColoredTextField.h"


@interface MMCollapsableStackView : MMTutorialStackView

@property (nonatomic, weak) NSObject<MMCollapsableStackViewDelegate>* stackDelegate;
@property (nonatomic, readonly) BOOL isPerfectlyAlignedIntoRow;

@property (nonatomic, readonly) CGRect rectForColorConsideration;
@property (nonatomic, readonly) MMColoredTextField* stackNameField;

- (void)organizePagesIntoSingleRowAnimated:(BOOL)animated;
- (void)organizePagesIntoListAnimated:(BOOL)animated;
- (void)cancelPendingConfirmationsAndResetToRow;

- (void)squashPagesWhenInRowView:(CGFloat)squash withTranslate:(CGFloat)translate;
- (CGPoint)effectiveRowCenter;
- (void)setNameColor:(UIColor*)color animated:(BOOL)animated;

- (NSArray*)pagesToAlignForRowView;

- (void)ensureAtLeastPagesInStack:(NSInteger)numberOfPages;

- (void)showCollapsedAnimation:(void (^)())onComplete;

- (void)exportToPDF:(void (^)(NSURL* urlToPDF))completionBlock;

@end
