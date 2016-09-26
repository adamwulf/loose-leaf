//
//  MMFeedbackViewController.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/26/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMFeedbackViewController.h"
#import "MMFeedbackView.h"


@interface MMFeedbackViewController () <MMRoundedSquareViewDelegate>

@end


@implementation MMFeedbackViewController {
    void (^completionBlock)();
}

- (instancetype)initWithCompletionBlock:(void (^)())_completionBlock {
    if (self = [super init]) {
        completionBlock = _completionBlock;
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    return self;
}


- (void)loadView {
    MMFeedbackView* releaseNotesView = [[MMFeedbackView alloc] initWithFrame:[[[UIScreen mainScreen] fixedCoordinateSpace] bounds]];
    releaseNotesView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    releaseNotesView.delegate = self;

    self.view = releaseNotesView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MMRoundedSquareViewDelegate

- (void)didTapToCloseRoundedSquareView:(MMRoundedSquareView*)squareView {
    if (completionBlock) {
        completionBlock();
    }
}

@end
