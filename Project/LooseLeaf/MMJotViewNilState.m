//
//  MMJotViewNilState.m
//  LooseLeaf
//
//  Created by Adam Wulf on 10/1/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMJotViewNilState.h"

@implementation MMJotViewNilState

static MMJotViewNilState* _instance = nil;

-(id) init{
    if(_instance) return _instance;
    if((self = [super init])){
        // noop
    }
    return _instance;
}

+(MMJotViewNilState*) sharedInstance{
    if(!_instance){
        _instance = [[MMJotViewNilState alloc] init];
    }
    return _instance;
}



+(dispatch_queue_t) loadUnloadStateQueue{
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,(unsigned long)NULL);
}

-(NSObject<JotViewStateProxyDelegate>*) delegate{
    return nil;
}
-(JotViewState*) jotViewState{
    return nil;
}
-(NSMutableArray*) strokesBeingWrittenToBackingTexture{
    return nil;
}

-(JotGLTextureBackedFrameBuffer*) backgroundFramebuffer{
    return nil;
}

-(JotStroke*) currentStroke{
    return nil;
}

-(int) fullByteSize{
    return 0;
}

-(id) initWithDelegate:(NSObject<JotViewStateProxyDelegate>*)delegate{
    return [MMJotViewNilState sharedInstance];
}

-(BOOL) isStateLoaded{
    return YES;
}

-(BOOL) isReadyToExport{
    return NO;
}

-(JotViewImmutableState*) immutableState{
    return nil;
}

-(JotGLTexture*) backgroundTexture{
    return nil;
}

-(NSArray*) everyVisibleStroke{
    return @[];
}

-(JotBufferManager*) bufferManager{
    return [JotBufferManager sharedInstance];
}

-(void) tick{
    // noop
}

-(NSUInteger) undoHash{
    return 0;
}

-(void) loadStateAsynchronously:(BOOL)async withSize:(CGSize)pagePtSize andScale:(CGFloat)scale andContext:(JotGLContext*)context andBufferManager:(JotBufferManager*)bufferManager{
    // noop
}

-(void) unload{
    // noop
}

-(BOOL) hasEditsToSave{
    return NO;
}

-(void) wasSavedAtImmutableState:(JotViewImmutableState*)immutableState{
    // noop
}

#pragma mark - Undo Redo

-(BOOL) canUndo{
    return NO;
}

-(BOOL) canRedo{
    return NO;
}

-(JotStroke*) undo{
    return nil;
}

-(JotStroke*) redo{
    return nil;
}

// same as undo, except the undone
// stroke is not added to the redo stack
-(JotStroke*) undoAndForget{
    return nil;
}

// closes the current stroke and adds it to the
// undo stack
-(void) finishCurrentStroke{
    // noop
}


-(void) addUndoLevelAndFinishStrokeWithBrush:(JotBrushTexture*)brushTexture{
    // noop
}

-(void) forceAddEmptyStrokeWithBrush:(JotBrushTexture*)brushTexture{
    // noop
}

// adds the input stroke to the undo stack
// w/o clearing the undone strokes
-(void) forceAddStroke:(JotStroke*)stroke{
    // noop
}

-(void) clearAllStrokes{
    // noop
}

// returns the new stroke that is the continuation
// of the currentStroke
-(void) addUndoLevelAndContinueStrokeWithBrush:(JotBrushTexture*)brushTexture{
    // noop
}

#pragma mark - Debug

-(NSUInteger) currentStateUndoHash{
    return 0;
}

-(NSUInteger) lastSavedUndoHash{
    return 0;
}


@end
