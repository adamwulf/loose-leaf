//
//  MMEditablePaperView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 5/24/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMPaperView.h"
#import <JotUI/JotUI.h>

@interface MMEditablePaperView : MMPaperView<JotViewDelegate>{
    UIImageView* cachedImgView;
    JotView* drawableView;
    
    UIImageView* testImageView;
}

-(void) undo;
-(void) redo;
-(void) saveToDisk:(void(^)(void))onComplete;
-(void) setEditable:(BOOL)isEditable;

@end
