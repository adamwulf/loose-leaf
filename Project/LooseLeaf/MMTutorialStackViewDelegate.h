//
//  MMTutorialStackViewDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/26/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMPaperStackViewDelegate.h"

@class MMTutorialStackView;

@protocol MMTutorialStackViewDelegate <MMPaperStackViewDelegate>

- (void)stackViewDidPressFeedbackButton:(MMTutorialStackView*)stackView;

@end
