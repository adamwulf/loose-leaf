//
//  MMUndoRedoItem.h
//  LooseLeaf
//
//  Created by Adam Wulf on 7/2/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MMUndoRedoItem <NSObject>

-(void) undo;

-(void) redo;

@end
