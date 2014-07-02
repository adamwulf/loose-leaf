//
//  MMUndoablePaperView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/2/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMUndoablePaperView.h"

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

-(void) undo{
    NSLog(@"undo!");
    [super undo];
}

-(void) redo{
    NSLog(@"redo!");
    [super redo];
}

@end
