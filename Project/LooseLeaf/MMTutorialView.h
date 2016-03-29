//
//  MMTutorialView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 2/21/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMTutorialViewDelegate.h"
#import "MMRoundedSquareView.h"

@interface MMTutorialView : MMRoundedSquareView<UIScrollViewDelegate>

@property (nonatomic, weak) NSObject<MMTutorialViewDelegate>* delegate;

-(id) initWithFrame:(CGRect)frame andTutorials:(NSArray*)tutorialList;

-(void) unloadTutorials;

@end
