//
//  MMExportablePaperView+Trash.m
//  LooseLeaf
//
//  Created by Adam Wulf on 10/8/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMExportablePaperView+Trash.h"
#import "JotViewStateProxy+Trash.h"
#import "MMScrapViewState+Trash.h"
#import "MMPageUndoRedoManager+Trash.h"
#import "MMScrapCollectionState+Trash.h"

@implementation MMExportablePaperView (Trash)

-(void) forgetAllPendingEdits{
    for(MMScrapView* scrap in self.scrapsOnPaper){
        [scrap.state forgetAllPendingEdits];
    }
    paperState.isForgetful = YES;
    undoRedoManager.isForgetful = YES;
    scrapsOnPaperState.isForgetful = YES;
}

@end
