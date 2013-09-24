//
//  MMEditablePaperViewDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/24/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMPaperViewDelegate.h"

@class MMEditablePaperView;

@protocol MMEditablePaperViewDelegate <MMPaperViewDelegate>

-(void) didLoadStateForPage:(MMEditablePaperView*) page;

-(void) didUnloadStateForPage:(MMEditablePaperView*) page;

@end
