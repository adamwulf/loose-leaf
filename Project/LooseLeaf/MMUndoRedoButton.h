//
//  MMUndoRedoButton.h
//  LooseLeaf
//
//  Created by Adam Wulf on 5/31/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMSidebarButton.h"


@interface MMUndoRedoButton : MMSidebarButton {
    BOOL reverseArrow;
}

@property (nonatomic) BOOL reverseArrow;

@end
