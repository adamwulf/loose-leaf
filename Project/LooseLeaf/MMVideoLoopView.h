//
//  MMVideoLoopView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 2/21/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMLoopView.h"


@interface MMVideoLoopView : MMLoopView

- (id)initForVideo:(NSURL*)videoURL withTitle:(NSString*)_title forTutorialId:(NSString*)tutorialId;

@end
