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

@implementation MMUndoablePaperView{
    MMPageUndoRedoManager* undoRedoManager;
}

@synthesize undoRedoManager;

-(NSUndoManager*) undoManager{
    @throw [NSException exceptionWithName:@"MMUnknownUndoManager" reason:@"undoManager property is disabled" userInfo:nil];
}

- (id)initWithFrame:(CGRect)frame andUUID:(NSString*)_uuid{
    if (self = [super initWithFrame:frame andUUID:_uuid]) {
        // Initialization code
        undoRedoManager = [[MMPageUndoRedoManager alloc] init];
    }
    return self;
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
