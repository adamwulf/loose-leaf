//
//  SLListPaperStackView.m
//  scratchpaper
//
//  Created by Adam Wulf on 7/3/12.
//
//

#import "SLListPaperStackView.h"

@implementation SLListPaperStackView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(CGRect) zoomToListFrameForPage:(SLPaperView*)page oldToFrame:(CGRect)toFrame withTrust:(CGFloat)percentageToTrustToFrame{
    //
    // screen and column constants
    CGFloat screenWidth = self.frame.size.width;
    CGFloat screenHeight = self.frame.size.height;
    CGFloat columnWidth = screenWidth / 4;
    CGFloat columnHeight = columnWidth * screenHeight / screenWidth;
    CGFloat bufferWidth = columnWidth / 4;

    //
    // page column and row
    NSInteger indexOfPage = [visibleStackHolder.subviews indexOfObject:page];
    NSInteger columnOfPage = indexOfPage % 3;
    NSInteger rowOfPage = floor(indexOfPage / 3);

    //
    // for now, we'll assume the page is being pulled from
    // it's containers bounds
    CGRect oldFrame = toFrame;
    
    
    CGRect newFrame = toFrame;
    CGFloat finalX = bufferWidth + bufferWidth * columnOfPage + columnWidth * columnOfPage;
    CGFloat finalY = bufferWidth + bufferWidth * rowOfPage + columnHeight * rowOfPage;
    CGFloat currX = oldFrame.origin.x;
    CGFloat currY = oldFrame.origin.y;
    CGFloat currWidth = oldFrame.size.width;
    CGFloat currHeight = oldFrame.size.height;
    CGFloat finalWidth = kListPageZoom * screenWidth;
    CGFloat finalHeight = kListPageZoom * screenHeight;
    newFrame.origin.x = finalX - (finalX - currX) * percentageToTrustToFrame;
    newFrame.origin.y = finalY - (finalY - currY) * percentageToTrustToFrame;
    newFrame.size.width = finalWidth - (finalWidth - currWidth) * percentageToTrustToFrame;
    newFrame.size.height = finalHeight - (finalHeight - currHeight) * percentageToTrustToFrame;
    
    debug_NSLog(@"index:%d row:%d column: %d    x: %f  x2: %f", indexOfPage, rowOfPage, columnOfPage, toFrame.origin.x, newFrame.origin.x);
    return newFrame;
}



-(CGRect) isPanningAndScalingPage:(SLPaperView*)page fromFrame:(CGRect)fromFrame toFrame:(CGRect)toFrame{
    //
    // gestures for tiny pages aren't allowed
    if([visibleStackHolder peekSubview].scale < kMinPageZoom){
        
        if([[setOfPagesBeingPanned setByRemovingObject:[visibleStackHolder peekSubview]] count]){
            debug_NSLog(@"still pages being panned, this'll be caught by the isBeginningToScaleReallySmall handler");
            return toFrame;
        }
        if([bezelStackHolder.subviews count]){
            debug_NSLog(@"bezelStackHolder still has pages being animated, so hold off on any list animations for now");
            return toFrame;
        }
        CGFloat percentageToTrustToFrame = [visibleStackHolder peekSubview].scale / kMinPageZoom;
        
        
        NSInteger indexOfTopVisiblePage = [visibleStackHolder.subviews indexOfObject:page];
        NSInteger columnOfTopVisiblePage = indexOfTopVisiblePage % 3;
        NSInteger numberOfViewsBelowTopPageInList = MIN(3 + columnOfTopVisiblePage, [visibleStackHolder.subviews indexOfObject:page]);
        
        for(int i=0;i<numberOfViewsBelowTopPageInList;i++){
            if(indexOfTopVisiblePage - 1 - i > 0){
                SLPaperView* nonTopPage = [visibleStackHolder.subviews objectAtIndex:(indexOfTopVisiblePage - 1 - i)];
                nonTopPage.frame = [self zoomToListFrameForPage:nonTopPage oldToFrame:visibleStackHolder.bounds withTrust:percentageToTrustToFrame];
            }
        }
        
        if([visibleStackHolder peekSubview].scale < kZoomToListPageZoom){
            [[visibleStackHolder peekSubview] cancelAllGestures];
        }
        return [self zoomToListFrameForPage:page oldToFrame:toFrame withTrust:percentageToTrustToFrame];
    }
    return [super isPanningAndScalingPage:page fromFrame:fromFrame toFrame:toFrame];
}

#pragma mark - SLPaperViewDelegate - List View

-(void) isBeginningToScaleReallySmall:(SLPaperView *)page{
    debug_NSLog(@"is small scale");
    
    if([[setOfPagesBeingPanned setByRemovingObject:page] count]){
        debug_NSLog(@"need to cancel some stuff");
        //
        // we're panning the top most page, and it's scale
        // is less than the minimum allowed.
        //
        // this means we need to cancel all other gestures
        // and start zooming views out
        NSSet* setOfAllPannedPagesExceptTopVisible = [setOfPagesBeingPanned setByRemovingObject:[visibleStackHolder peekSubview]];
        for(SLPaperView* page in setOfAllPannedPagesExceptTopVisible){
            [page cancelAllGestures];
        }
    }
    if([bezelStackHolder.subviews count]){
        debug_NSLog(@"need to clean up bezel");
        [self emptyBezelStackToHiddenStackAnimated:YES onComplete:^(BOOL finished){
            if(finished){
                // recur
                [self isBeginningToScaleReallySmall:page];
            }
        }];
    }else{
        debug_NSLog(@"we're ok to begin zooming pages to location in list view");
    }
}

-(void) finishedScalingReallySmall:(SLPaperView *)page{
    
    [page disableAllGestures];
    
    NSInteger indexOfTopVisiblePage = [visibleStackHolder.subviews indexOfObject:page];
    NSInteger columnOfTopVisiblePage = indexOfTopVisiblePage % 3;
    NSInteger numberOfViewsBelowTopPageInList = MIN(3 + columnOfTopVisiblePage, [visibleStackHolder.subviews indexOfObject:page]);
    
    debug_NSLog(@"finished small scale");
    [UIView beginAnimations:@"pages" context:nil];
    [UIView setAnimationDelay:1.0];
    [UIView setAnimationDuration:3.0];
    for(int i=0;i<numberOfViewsBelowTopPageInList + 1;i++){
        if(indexOfTopVisiblePage - i >= 0){
            SLPaperView* aPage = [visibleStackHolder.subviews objectAtIndex:(indexOfTopVisiblePage - i)];
            CGRect rect = [self zoomToListFrameForPage:aPage oldToFrame:page.frame withTrust:0.0];
            aPage.frame = rect;
        }
    }
    [UIView commitAnimations];
}

-(void) cancelledScalingReallySmall:(SLPaperView *)page{
    debug_NSLog(@"cancelled small scale");
}




@end
