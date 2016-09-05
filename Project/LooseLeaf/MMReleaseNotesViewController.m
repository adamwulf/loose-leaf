//
//  MMReleaseNotesViewController.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/5/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMReleaseNotesViewController.h"
#import "MMReleaseNotesView.h"

@interface MMReleaseNotesViewController ()<MMRoundedSquareViewDelegate>

@end

@implementation MMReleaseNotesViewController{
    NSString* releaseNotes;
    void(^completionBlock)();
}

-(instancetype) initWithReleaseNotes:(NSString*)_releaseNotes andCompletionBlock:(void(^)())_completionBlock{
    if(self = [super init]){
        releaseNotes = _releaseNotes;
        completionBlock = _completionBlock;
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    return self;
}


-(void) loadView{
    MMReleaseNotesView* releaseNotesView = [[MMReleaseNotesView alloc] initWithFrame:[[[UIScreen mainScreen] fixedCoordinateSpace] bounds] andReleaseNotes:releaseNotes];
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

-(void) didTapToCloseRoundedSquareView:(MMRoundedSquareView*)squareView{
    if(completionBlock){
        completionBlock();
    }
}


@end
