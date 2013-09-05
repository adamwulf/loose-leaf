//
//  UIView+SubviewStacks.h
//  Loose Leaf
//
//  Created by Adam Wulf on 6/20/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMEditablePaperView.h"
#import "MMScrappedPaperView.h"

@interface UIView (SubviewStacks)

- (BOOL) containsSubview:(MMPaperView*)obj;
- (MMScrappedPaperView*) peekSubview;
- (MMScrappedPaperView*) popSubview;
- (MMScrappedPaperView*) bottomSubview;
- (void) insertSubview:(MMPaperView*)obj;
- (void) pushSubview:(MMPaperView*)obj;
- (void) addSubviewToBottomOfStack:(MMPaperView*)obj;
- (NSArray*) peekSubviewFromSubview:(MMPaperView*)obj;
- (MMScrappedPaperView*) getPageBelow:(MMPaperView*)page;
-(MMScrappedPaperView*) getPageAbove:(MMPaperView*)page;
-(void) insertPage:(MMPaperView*)pageToInsert belowPage:(MMPaperView*)referencePage;
-(void) insertPage:(MMPaperView*)pageToInsert abovePage:(MMPaperView*)referencePage;

@end
