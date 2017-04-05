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
#import "MMBackgroundStyleContainerViewDelegate.h"

@interface MMCollapsableStackView : MMTutorialStackView<MMBackgroundStyleContainerViewDelegate>

+ (CGRect)shareStackButtonFrame;

@property (nonatomic, weak) NSObject<MMCollapsableStackViewDelegate>* stackDelegate;
@property (nonatomic, readonly) BOOL isPerfectlyAlignedIntoRow;
@property (nonatomic, readonly) BOOL isCurrentlyHandlingImport;

@property (nonatomic, readonly) CGRect rectForColorConsideration;
@property (nonatomic, readonly) UIView* stackNameField;

- (void)organizePagesIntoSingleRowAnimated:(BOOL)animated;
- (void)organizePagesIntoListAnimated:(BOOL)animated;
- (void)cancelPendingConfirmationsAndResetToRow;

- (void)squashPagesWhenInRowView:(CGFloat)squash withTranslate:(CGFloat)translate;
- (CGPoint)effectiveRowCenter;
- (void)setNameColor:(UIColor*)color animated:(BOOL)animated;

- (NSArray*)pagesToAlignForRowView;

- (void)ensureAtLeastPagesInStack:(NSInteger)numberOfPages;

- (void)showCollapsedAnimation:(void (^)())onComplete;

- (void)exportStackToPDF:(void (^)(NSURL* urlToPDF))completionBlock withProgress:(BOOL (^)(NSInteger pageSoFar, NSInteger totalPages))progressBlock;

- (void)showUIToPrepareForImportingPDF:(MMPDFInboxItem*)pdfDoc onComplete:(void (^)())completionBlock;

- (void)importAllPagesFromPDFInboxItem:(MMPDFInboxItem*)pdfDoc fromSourceApplication:(NSString*)sourceApplication onComplete:(void (^)(BOOL success))completionBlock;

@end
