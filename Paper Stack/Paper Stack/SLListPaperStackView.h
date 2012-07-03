//
//  SLListPaperStackView.h
//  scratchpaper
//
//  Created by Adam Wulf on 7/3/12.
//
//

#import "SLPaperStackView.h"

@interface SLListPaperStackView : SLPaperStackView{
    //
    // when beginning a zoom, we need to save the
    // frames of all the pages we'll be animating
    //
    // then we'll use that saved frame value to
    // animate between it's final state
    NSMutableDictionary* setOfInitialFramesForPagesBeingZoomed;

    CGFloat screenWidth;
    CGFloat screenHeight;
    CGFloat columnWidth;
    CGFloat rowHeight;
    CGFloat bufferWidth;
    
    UITapGestureRecognizer* tapGesture;
}

@end
