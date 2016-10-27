//
//  MMTutorialStackView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 2/23/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMClonePaperStackView.h"
#import "MMTutorialStackViewDelegate.h"


@class MMLargeTutorialSidebarButton, MMFeedbackButton;


@interface MMTutorialStackView : MMClonePaperStackView {
    MMLargeTutorialSidebarButton* listViewTutorialButton;
    MMFeedbackButton* listViewFeedbackButton;
}

@property (nonatomic, weak) NSObject<MMTutorialStackViewDelegate>* stackDelegate;

@end
