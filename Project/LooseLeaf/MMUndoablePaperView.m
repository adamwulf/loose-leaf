//
//  MMUndoablePaperView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/2/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMUndoablePaperView.h"
#import "MMUndoRedoBlockItem.h"
#import "MMEditablePaperView+UndoRedo.h"
#import "MMUndoRedoStrokeItem.h"
#import "MMUndoRedoAddScrapItem.h"
#import "MMUndoRedoRemoveScrapItem.h"
#import "MMUndoRedoGroupItem.h"
#import "MMUndoRedoMoveScrapItem.h"

@interface MMScrappedPaperView (Queue)

+(dispatch_queue_t) concurrentBackgroundQueue;

@end


@implementation MMUndoablePaperView{
    MMPageUndoRedoManager* undoRedoManager;
    NSString* undoStatePath;
}

@synthesize undoRedoManager;

-(NSUndoManager*) undoManager{
    @throw [NSException exceptionWithName:@"MMUnknownUndoManager" reason:@"undoManager property is disabled" userInfo:nil];
}

- (id)initWithFrame:(CGRect)frame andUUID:(NSString*)_uuid{
    if (self = [super initWithFrame:frame andUUID:_uuid]) {
        // Initialization code
        undoRedoManager = [[MMPageUndoRedoManager alloc] initForPage:self];
    }
    return self;
}

#pragma mark - Scrap Loading

-(NSArray*) scrapsOnPaper{
    // also tie in here and append any scraps
    // that are in the undo manager (?)
    return [super scrapsOnPaper];
}

-(void) didLoadScrap:(MMScrapView *)scrap{
    // should i tie in here to give scraps to undo objects?
    [super didLoadScrap:scrap];
}

#pragma mark - Saving and Loading

-(void) saveToDisk:(void (^)(BOOL))onComplete{
    // track if our back ground page has saved
    dispatch_semaphore_t sema1 = dispatch_semaphore_create(0);
    // track if all of our scraps have saved
    dispatch_semaphore_t sema2 = dispatch_semaphore_create(0);

    if(!undoRedoManager){
        NSLog(@"what");
    }
    
    __block BOOL hadEditsToSave;
    [super saveToDisk:^(BOOL _hadEditsToSave){
        // save all our ink/strokes/thumbs/etc to disk
        hadEditsToSave = _hadEditsToSave;
        dispatch_semaphore_signal(sema1);
    }];
    dispatch_async([MMScrappedPaperView concurrentBackgroundQueue], ^(void) {
        // also write undostack to disk
        [undoRedoManager saveTo:[self undoStatePath]];
        dispatch_semaphore_signal(sema2);
    });
    
    dispatch_async([MMScrappedPaperView concurrentBackgroundQueue], ^(void) {
        @autoreleasepool {
            dispatch_semaphore_wait(sema1, DISPATCH_TIME_FOREVER);
            dispatch_semaphore_wait(sema2, DISPATCH_TIME_FOREVER);
            
            if(onComplete) onComplete(hadEditsToSave);
        }
    });
}

-(void) loadStateAsynchronously:(BOOL)async withSize:(CGSize)pagePixelSize andContext:(JotGLContext *)context{
    [super loadStateAsynchronously:async withSize:pagePixelSize andContext:context];
    
    dispatch_block_t block = ^{
        [undoRedoManager loadFrom:[self undoStatePath]];
    };
    
    if(async){
        dispatch_async([MMScrappedPaperView concurrentBackgroundQueue], block);
    }else{
        block();
    }
}

-(void) unloadState{
    [super unloadState];
    [undoRedoManager unloadState];
}

#pragma mark - Undo / Redo of JotViews

-(void) undo{
    [super undo];
    [self debugPrintUndoStatus];
}

-(void) redo{
    [super redo];
    [self debugPrintUndoStatus];
}

#pragma mark - Methods That Trigger Undo

-(void) addUndoItemForScrap:(MMScrapView*)scrap thatMovedFrom:(NSDictionary*)startProperties to:(NSDictionary*)endProperties{
    NSLog(@"moved scrap on same page");
    [self.undoRedoManager addUndoItem:[MMUndoRedoMoveScrapItem itemForPage:self andScrap:scrap from:startProperties to:endProperties]];
}

-(void) addUndoItemForRemovedScrap:(MMScrapView*)scrap{
    [self.undoRedoManager addUndoItem:[MMUndoRedoRemoveScrapItem itemForPage:self andScrap:scrap]];
}

-(void) addUndoItemForAddedScrap:(MMScrapView*)scrap{
    [self.undoRedoManager addUndoItem:[MMUndoRedoAddScrapItem itemForPage:self andScrap:scrap]];
}

-(MMScissorResult*) completeScissorsCutWithPath:(UIBezierPath *)scissorPath{
    MMScissorResult* result = [super completeScissorsCutWithPath:scissorPath];
    
    if([result.addedScraps count] || [result.removedScraps count]){
        NSMutableArray* undoItems = [NSMutableArray array];
        if([result didAddFillStroke]){
            [undoItems addObject:[MMUndoRedoStrokeItem itemForPage:self]];
        }
        for (MMScrapView* scrap in result.addedScraps) {
            [undoItems addObject:[MMUndoRedoAddScrapItem itemForPage:self andScrap:scrap]];
        }
        for (MMScrapView* scrap in result.removedScraps) {
            [undoItems addObject:[MMUndoRedoRemoveScrapItem itemForPage:self andScrap:scrap]];
        }
        
        [self.undoRedoManager addUndoItem:[MMUndoRedoGroupItem itemForPage:self withItems:undoItems]];
    }
    
    return result;
}

-(void) addStandardStrokeUndoItem{
    [self.undoRedoManager addUndoItem:[MMUndoRedoStrokeItem itemForPage:self]];
}

-(void) didEndStrokeWithTouch:(JotTouch *)touch{
    [super didEndStrokeWithTouch:touch];
    [self addStandardStrokeUndoItem];
    [self debugPrintUndoStatus];
}

-(void) didCancelStroke:(JotStroke *)stroke withTouch:(JotTouch *)touch{
    [super didCancelStroke:stroke withTouch:touch];
    // no undo change needed
    [self debugPrintUndoStatus];
}

-(void) addUndoLevelAndContinueStroke{
    [super addUndoLevelAndContinueStroke];
    [self addStandardStrokeUndoItem];
}

#pragma mark - Paths

-(NSString*) undoStatePath{
    if(!undoStatePath){
        undoStatePath = [[[self pagesPath] stringByAppendingPathComponent:@"undoRedo"] stringByAppendingPathExtension:@"plist"];
    }
    return undoStatePath;
}


#pragma mark - Debug

-(void) debugPrintUndoStatus{
    
    NSLog(@"**********************************************************************");
    NSLog(@"Undo status");
    NSLog(@" page %@", self.uuid);
    NSLog(@"   currentStroke: %p", self.drawableView.state.currentStroke);
    NSLog(@"   undoable stack: %i", (int)[self.drawableView.state.stackOfStrokes count]);
    NSLog(@"   undone stack:   %i", (int)[self.drawableView.state.stackOfUndoneStrokes count]);
    NSLog(@"scraps:");
    for(MMScrapView* scrap in [self.scrapsOnPaper reverseObjectEnumerator]){
        NSLog(@" scrap %@", scrap.uuid);
        NSLog(@"   currentStroke: %p", scrap.state.drawableView.state.currentStroke);
        NSLog(@"   undoable stack: %i", (int)[scrap.state.drawableView.state.stackOfStrokes count]);
        NSLog(@"   undone stack:   %i", (int)[scrap.state.drawableView.state.stackOfUndoneStrokes count]);
    }
    NSLog(@"**********************************************************************");
}


@end
