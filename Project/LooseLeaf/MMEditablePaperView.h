//
//  MMEditablePaperView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 5/24/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMPaperView.h"
#import <JotUI/JotUI.h>
#import "Pen.h"

@interface MMEditablePaperView : MMPaperView<JotViewDelegate>{
    JotView* drawableView;
    Pen* pen;
}

@end
