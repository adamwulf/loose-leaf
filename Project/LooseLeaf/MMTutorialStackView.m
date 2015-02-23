//
//  MMTutorialStackView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 2/23/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMTutorialStackView.h"
#import "MMTutorialView.h"

@implementation MMTutorialStackView{
    UIView* backdrop;
    MMTutorialView* tutorialView;
}

-(id) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        
        backdrop = [[UIView alloc] initWithFrame:self.bounds];
        backdrop.backgroundColor = [UIColor whiteColor];
        [self addSubview:backdrop];
        
        tutorialView = [[MMTutorialView alloc] initWithFrame:self.bounds];
        tutorialView.delegate = self;
        [self addSubview:tutorialView];
    }
    return self;
}

#pragma mark - MMTutorialViewDelegate

-(void) didFinishTutorial{
    [UIView animateWithDuration:.3 animations:^{
        backdrop.alpha = 0;
        tutorialView.alpha = 0;
    } completion:^(BOOL finished) {
        [backdrop removeFromSuperview];
        backdrop = nil;
        [tutorialView removeFromSuperview];
        tutorialView = nil;
    }];
}

@end
