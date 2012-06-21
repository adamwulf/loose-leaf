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
- (void)pushSubview:(SLPaperView*)obj;
- (void) addSubviewToBottomOfStack:(SLPaperView*)obj;
- (NSArray*) peekSubviewFromSubview:(SLPaperView*)obj;

@end
