//
//  MMUndoRedoBlockItem.h
//  LooseLeaf
//
//  Created by Adam Wulf on 7/2/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMUndoRedoItem.h"

@interface MMUndoRedoBlockItem : NSObject<MMUndoRedoItem>

+(MMUndoRedoBlockItem*) itemWithUndoBlock:(void(^)())undoBlock andRedoBlock:(void(^)())redoBlock;

@end
