//
//  MMPaperState.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/24/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMPaperState.h"
#import <JotUI/JotUI.h>
#import "MMEditablePaperView.h"

@implementation MMPaperState{
    BOOL shouldKeepStateLoaded;
    BOOL isLoadingState;
    CGSize pagePixelSize;
    
    NSUInteger lastSavedUndoHash;
    JotViewState* jotViewState;
    
    NSString* inkPath;
    NSString* plistPath;
}

@synthesize delegate;
@synthesize jotViewState;

-(id) initWithInkPath:(NSString*)_inkPath andPlistPath:(NSString*)_plistPath{
    if(self = [super init]){
        inkPath = _inkPath;
        plistPath = _plistPath;
    }
    return self;
}

-(void) loadStateAsynchronously:(BOOL)async withSize:(CGSize)_pagePixelSize andContext:(JotGLContext*)context andStartPage:(BOOL)startPage{
    @synchronized(self){
        // if we're already loading our
        // state, then bail early
        if(isLoadingState) return;
        // if we already have our state,
        // then bail early
        if(jotViewState) return;
        
        shouldKeepStateLoaded = YES;
        isLoadingState = YES;
    }
    
    pagePixelSize = _pagePixelSize;

    void (^block2)() = ^(void) {
        @autoreleasepool {
            if(!jotViewState){
                jotViewState = [[JotViewState alloc] initWithImageFile:inkPath
                                                          andStateFile:plistPath
                                                           andPageSize:pagePixelSize
                                                          andGLContext:context
                                                      andBufferManager:[JotBufferManager sharedInstace]];
                lastSavedUndoHash = [jotViewState undoHash];

                if(startPage){
                    [self setBackgroundTextureToStartPage];
                }
                
                @synchronized(self){
                    isLoadingState = NO;
                    if(shouldKeepStateLoaded){
                        // nothing changed in our goals since we started
                        // to load state, so notify our delegate
                        [self.delegate didLoadState:self];
                    }else{
                        // when loading state, we were actually
                        // told that we didn't really need the
                        // state after all, so just throw it away :(
                        jotViewState = nil;
                    }
                }
            }
        }
    };
    
    if(async){
        dispatch_async(([MMEditablePaperView loadUnloadStateQueue]), block2);
    }else{
        block2();
    }
}

-(void) wasSavedAtImmutableState:(JotViewImmutableState*)immutableState{
    lastSavedUndoHash = [immutableState undoHash];
}

-(void) unload{
    @synchronized(self){
        shouldKeepStateLoaded = NO;
        if(!isLoadingState && jotViewState){
            jotViewState = nil;
            pagePixelSize = CGSizeZero;
            [self.delegate didUnloadState:self];
        }
    }
}

-(BOOL) isStateLoaded{
    return jotViewState != nil;
}

/**
 * we have more information to save, if our
 * drawable view's hash does not equal to our
 * currently saved hash
 */
-(BOOL) hasEditsToSave{
    return [self.jotViewState undoHash] != lastSavedUndoHash;
}




#pragma mark - Alpha

-(void) setBackgroundTextureToStartPage{
    UIGraphicsBeginImageContext(pagePixelSize);
    CGFloat scale = [[UIScreen mainScreen] scale];
    
    CGFloat textStartX = 110;
    
    [@"←" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(70, 18), CGAffineTransformMakeScale(scale, scale))
             withFont:[UIFont systemFontOfSize:32 * scale]];
    [@"New Blank Page" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(textStartX, 25), CGAffineTransformMakeScale(scale, scale))
                          withFont:[UIFont systemFontOfSize:16 * scale]];
    
    
    [@"←" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(70, 18 + 60), CGAffineTransformMakeScale(scale, scale))
             withFont:[UIFont systemFontOfSize:32 * scale]];
    [@"Jot Touch Settings" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(textStartX, 25 + 60), CGAffineTransformMakeScale(scale, scale))
                              withFont:[UIFont systemFontOfSize:16 * scale]];
    
    
    
    [@"←" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(70, 298), CGAffineTransformMakeScale(scale, scale))
             withFont:[UIFont systemFontOfSize:32 * scale]];
    [@"Pen" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(textStartX, 310), CGAffineTransformMakeScale(scale, scale))
               withFont:[UIFont systemFontOfSize:16 * scale]];
    
    
    [@"←" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(70, 298 + 60), CGAffineTransformMakeScale(scale, scale))
             withFont:[UIFont systemFontOfSize:32 * scale]];
    [@"Eraser" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(textStartX, 310 + 60), CGAffineTransformMakeScale(scale, scale))
                  withFont:[UIFont systemFontOfSize:16 * scale]];
    
    [@"←" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(70, 298 + 60 * 2), CGAffineTransformMakeScale(scale, scale))
             withFont:[UIFont systemFontOfSize:32 * scale]];
    [@"Scraps!" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(textStartX, 310 + 60 * 2), CGAffineTransformMakeScale(scale, scale))
                  withFont:[UIFont systemFontOfSize:16 * scale]];
    
    [@"←" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(70, 330 + 60 * 5), CGAffineTransformMakeScale(scale, scale))
             withFont:[UIFont systemFontOfSize:32 * scale]];
    [@"Grab" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(textStartX, 342 + 60 * 5), CGAffineTransformMakeScale(scale, scale))
                withFont:[UIFont systemFontOfSize:16 * scale]];
    
    [@"←" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(70, 330 + 60 * 6), CGAffineTransformMakeScale(scale, scale))
             withFont:[UIFont systemFontOfSize:32 * scale]];
    [@"Ruler" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(textStartX, 342 + 60 * 6), CGAffineTransformMakeScale(scale, scale))
                 withFont:[UIFont systemFontOfSize:16 * scale]];
    
    
    [@"←" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(70, 902), CGAffineTransformMakeScale(scale, scale))
             withFont:[UIFont systemFontOfSize:32 * scale]];
    [@"Undo" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(textStartX, 914), CGAffineTransformMakeScale(scale, scale))
                withFont:[UIFont systemFontOfSize:16 * scale]];
    
    [@"←" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(70, 902 + 60), CGAffineTransformMakeScale(scale, scale))
             withFont:[UIFont systemFontOfSize:32 * scale]];
    [@"Redo" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(textStartX, 914 + 60), CGAffineTransformMakeScale(scale, scale))
                withFont:[UIFont systemFontOfSize:16 * scale]];
    
    
    
    
    [@"Thanks for helping test Loose Leaf!" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(250, 342), CGAffineTransformMakeScale(scale, scale))
                                               withFont:[UIFont boldSystemFontOfSize:20 * scale]];
    
    
    [@"New this build:" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(250, 402), CGAffineTransformMakeScale(scale, scale))
                           withFont:[UIFont boldSystemFontOfSize:20 * scale]];
    
    [@"• New Ruler mode lets you draw super straight lines" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(250, 442), CGAffineTransformMakeScale(scale, scale))
                                                               withFont:[UIFont systemFontOfSize:20 * scale]];
    [@"  or curves. Similar to Adobe's Napolean ruler." drawAtPoint:CGPointApplyAffineTransform(CGPointMake(250, 468), CGAffineTransformMakeScale(scale, scale))
                                                           withFont:[UIFont systemFontOfSize:20 * scale]];
    
    [@"• Two fingers from left bezel will move pages off the stack." drawAtPoint:CGPointApplyAffineTransform(CGPointMake(250, 508), CGAffineTransformMakeScale(scale, scale))
                                                                        withFont:[UIFont systemFontOfSize:20 * scale]];
    
    [@"• two fingers from either bezel works in ruler mode." drawAtPoint:CGPointApplyAffineTransform(CGPointMake(250, 548), CGAffineTransformMakeScale(scale, scale))
                                                                withFont:[UIFont systemFontOfSize:20 * scale]];
    
    [@"• Can move pages in list view with 1 finger long press." drawAtPoint:CGPointApplyAffineTransform(CGPointMake(250, 588), CGAffineTransformMakeScale(scale, scale))
                                                                   withFont:[UIFont systemFontOfSize:20 * scale]];
    
    [@"• lots of memory optimizations" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(250, 628), CGAffineTransformMakeScale(scale, scale))
                                          withFont:[UIFont systemFontOfSize:20 * scale]];
    
    [@"• changed perspective a bit when zooming to list" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(250, 668), CGAffineTransformMakeScale(scale, scale))
                                                            withFont:[UIFont systemFontOfSize:20 * scale]];
    
    [@"• thinner less smeared-looking pen" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(250, 708), CGAffineTransformMakeScale(scale, scale))
                                              withFont:[UIFont systemFontOfSize:20 * scale]];
    
    
    [@"Not yet built:" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(250, 760), CGAffineTransformMakeScale(scale, scale))
                          withFont:[UIFont boldSystemFontOfSize:20 * scale]];
    
    [@"• New undo/redo UIUX" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(250, 800), CGAffineTransformMakeScale(scale, scale))
                                withFont:[UIFont systemFontOfSize:20 * scale]];
    [@"• Can't delete pages yet" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(250, 840), CGAffineTransformMakeScale(scale, scale))
                                    withFont:[UIFont systemFontOfSize:20 * scale]];
    
    /**
     
     Thanks for helping to test Loose Leaf!
     
     • one finger will draw
     
     • two fingers will pinch/grab a page
     
     • you can pinch and draw at the same time
     
     
     */
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    jotViewState.backgroundTexture = [[JotGLTexture alloc] initForImage:image withSize:pagePixelSize];
    lastSavedUndoHash = 0;
}

@end
