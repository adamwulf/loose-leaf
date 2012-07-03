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
    debug_NSLog(@"ok, begin zooming to list view %f complete", percentageToTrustToFrame);
    NSInteger indexOfTopVisiblePage = [visibleStackHolder.subviews count];
    NSInteger columnOfTopVisiblePage = (indexOfTopVisiblePage - 1) % 3;
    NSInteger rowOfTopVisiblePage = floor((indexOfTopVisiblePage - 1) / 3);
    NSInteger indexOfPage = [visibleStackHolder.subviews indexOfObject:page];
    NSInteger columnOfPage = (indexOfPage - 1) % 3;
    NSInteger rowOfPage = floor((indexOfPage - 1) / 3);
    CGFloat screenWidth = self.frame.size.width;
    CGFloat screenHeight = self.frame.size.height;
    CGFloat columnWidth = screenWidth / 4;
    CGFloat columnHeight = columnWidth * screenHeight / screenWidth;
    CGFloat bufferWidth = columnWidth / 4;
    CGRect newFrame = toFrame;
    CGFloat finalX = bufferWidth + bufferWidth * columnOfPage + columnWidth * columnOfPage;
    CGFloat finalY = bufferWidth + bufferWidth * (rowOfTopVisiblePage - rowOfPage) + columnHeight * (rowOfTopVisiblePage - rowOfPage);
    CGFloat currX = toFrame.origin.x;
    CGFloat currY = toFrame.origin.y;
    CGFloat currWidth = screenWidth;
    CGFloat currHeight = screenHeight;
    CGFloat finalWidth = kListPageZoom * screenWidth;
    CGFloat finalHeight = kListPageZoom * screenHeight;
    newFrame.origin.x = finalX - (finalX - currX) * percentageToTrustToFrame;
    newFrame.origin.y = finalY - (finalY - currY) * percentageToTrustToFrame;
    if(page != [visibleStackHolder peekSubview]){
        newFrame.size.width = finalWidth - (finalWidth - currWidth) * percentageToTrustToFrame;
        newFrame.size.height = finalHeight - (finalHeight - currHeight) * percentageToTrustToFrame;
    }
    
    debug_NSLog(@"index: %d  column: %d    x: %f  x2: %f", indexOfPage, columnOfPage, toFrame.origin.x, newFrame.origin.x);
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
        NSInteger columnOfTopVisiblePage = (indexOfTopVisiblePage - 1) % 3;
        NSInteger numberOfViewsAboveTopPageInList = MIN(6 + columnOfTopVisiblePage, [visibleStackHolder.subviews indexOfObject:page]);
        
        for(int i=0;i<numberOfViewsAboveTopPageInList;i++){
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
    NSInteger indexOfTopVisiblePage = [visibleStackHolder.subviews indexOfObject:page];
    NSInteger columnOfTopVisiblePage = (indexOfTopVisiblePage - 1) % 3;
    NSInteger numberOfViewsAboveTopPageInList = MIN(6 + columnOfTopVisiblePage, [visibleStackHolder.subviews indexOfObject:page]);
    
    debug_NSLog(@"finished small scale");
    [UIView beginAnimations:@"pages" context:nil];
    [UIView setAnimationDelay:3.0];
    [UIView setAnimationDuration:3.0];
    for(int i=0;i<numberOfViewsAboveTopPageInList + 1;i++){
        if(indexOfTopVisiblePage - i > 0){
            SLPaperView* nonTopPage = [visibleStackHolder.subviews objectAtIndex:(indexOfTopVisiblePage - i)];
            CGRect rect = [self zoomToListFrameForPage:nonTopPage oldToFrame:visibleStackHolder.bounds withTrust:0.0];
            debug_NSLog(@"newfr: x:%f y:%f w:%f h:%f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
            nonTopPage.frame = rect;
        }
    }
    [UIView commitAnimations];
}

-(void) cancelledScalingReallySmall:(SLPaperView *)page{
    debug_NSLog(@"cancelled small scale");
}




@end
