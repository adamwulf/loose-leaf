//
//  UIView+SubviewStacks.h
//  Loose Leaf
//
//  Created by Adam Wulf on 6/20/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMEditablePaperView.h"

@interface UIView (SubviewStacks)

- (BOOL) containsSubview:(MMPaperView*)obj;
- (MMEditablePaperView*) peekSubview;
- (MMEditablePaperView*) popSubview;
- (MMEditablePaperView*) bottomSubview;
- (void) insertSubview:(MMPaperView*)obj;
- (void) pushSubview:(MMPaperView*)obj;
- (void) addSubviewToBottomOfStack:(MMPaperView*)obj;
- (NSArray*) peekSubviewFromSubview:(MMPaperView*)obj;
- (MMEditablePaperView*) getPageBelow:(MMPaperView*)page;
-(MMEditablePaperView*) getPageAbove:(MMPaperView*)page;
-(void) insertPage:(MMPaperView*)pageToInsert belowPage:(MMPaperView*)referencePage;
-(void) insertPage:(MMPaperView*)pageToInsert abovePage:(MMPaperView*)referencePage;

@end
