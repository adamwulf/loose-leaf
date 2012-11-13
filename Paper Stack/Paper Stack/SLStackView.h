//
//  SLStackView.h
//  scratchpaper
//
//  Created by Adam Wulf on 11/12/12.
//
//

#import <UIKit/UIKit.h>
#import "SLPaperView.h"

@interface SLStackView : UIView

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
