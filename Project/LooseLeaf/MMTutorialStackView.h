//
//  MMTutorialStackView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 2/23/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMScrapPaperStackView.h"
#import "MMTutorialStackViewDelegate.h"


@interface MMTutorialStackView : MMScrapPaperStackView

@property (nonatomic, weak) NSObject<MMTutorialStackViewDelegate>* stackDelegate;

@end
