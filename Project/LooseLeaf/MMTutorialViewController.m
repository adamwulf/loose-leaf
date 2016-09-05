//
//  MMTutorialViewController.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/5/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMTutorialViewController.h"
#import "MMTutorialView.h"
#import "MMTutorialManager.h"
#import "Constants.h"

@interface MMTutorialViewController ()<MMTutorialViewDelegate>

@end

@implementation MMTutorialViewController{
    NSArray* tutorialList;
    void(^completionBlock)();
}

-(instancetype) initWithTutorials:(NSArray*)_tutorialList andCompletionBlock:(void(^)())_completionBlock{
    if(self = [super init]){
        tutorialList = _tutorialList;
        completionBlock = _completionBlock;
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    return self;
}


-(void) loadView{
    MMTutorialView* tutorialView = [[MMTutorialView alloc] initWithFrame:[[[UIScreen mainScreen] fixedCoordinateSpace] bounds] andTutorials:tutorialList];
    tutorialView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tutorialView.delegate = self;
    
    self.view = tutorialView;
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

-(void) didTapToCloseRoundedSquareView:(MMRoundedSquareView*)squareView{
    if(completionBlock){
        completionBlock();
    }
}

-(void) userIsViewingTutorialStep:(NSInteger)stepNum{
    DebugLog(@"User is watching tutorial %ld", (long)stepNum);
}

-(void) didFinishTutorial{
    [[MMTutorialManager sharedInstance] finishWatchingTutorial];
}

-(void) closeTutorials{
    if(completionBlock){
        completionBlock();
    }
}

@end
