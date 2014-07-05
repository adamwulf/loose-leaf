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

#pragma mark - Saving

-(void) saveToDisk:(void (^)(BOOL))onComplete{
    // track if our back ground page has saved
    dispatch_semaphore_t sema1 = dispatch_semaphore_create(0);
    // track if all of our scraps have saved
    dispatch_semaphore_t sema2 = dispatch_semaphore_create(0);

    
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
}

-(void) unloadState{
    [super unloadState];
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
