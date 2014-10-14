//
//  MMRotateViewController.m
//  LooseLeaf
//
//  Created by Adam Wulf on 10/13/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMRotateViewController.h"
#import "MMUntouchableView.h"
#import "MMPresentationWindow.h"

@implementation MMRotateViewController

-(id) initWithWindow:(MMPresentationWindow*)_window{
    if(self = [super init]){
        window = _window;
    }
    return self;
}

-(void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    window.shouldRespectKeyWindowRequest = NO;
    [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        window.shouldRespectKeyWindowRequest = YES;
    }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(NSUInteger) supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
}

-(BOOL) shouldAutorotate{
    return YES;
}


@end
