//
//  UIView+SubviewStacks.h
//  Paper Stack
//
//  Created by Adam Wulf on 6/20/12.
//  Copyright (c) 2012 Visere. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLPaperView.h"

@interface UIView (SubviewStacks)

- (BOOL) containsSubview:(SLPaperView*)obj;
- (SLPaperView*) peekSubview;
- (SLPaperView*)popSubview;
- (SLPaperView*)bottomSubview;
- (void)pushSubview:(SLPaperView*)obj;
- (void) addSubviewToBottomOfStack:(SLPaperView*)obj;
- (NSArray*) peekSubviewFromSubview:(SLPaperView*)obj;
- (SLPaperView*) getPageBelow:(SLPaperView*)page;
-(SLPaperView*) getPageAbove:(SLPaperView*)page;
-(void) insertPage:(SLPaperView*)pageToInsert belowPage:(SLPaperView*)referencePage;
-(void) insertPage:(SLPaperView*)pageToInsert abovePage:(SLPaperView*)referencePage;

@end
