//
//  MMImageLoopView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 4/22/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMLoopView.h"

@interface MMImageLoopView : MMLoopView

-(id) initForImage:(NSURL*)imageURL withTitle:(NSString*)title forTutorialId:(NSString*)tutorialId;

@end
