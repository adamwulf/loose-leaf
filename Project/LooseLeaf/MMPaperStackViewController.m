//
//  MMViewController.m
//  Loose Leaf
//
//  Created by Adam Wulf on 6/7/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "MMPaperStackViewController.h"
#import "MMShadowManager.h"
#import "MMEditablePaperView.h"

@interface MMLooseLeafViewController ()

@end

@implementation MMLooseLeafViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    srand ( time(NULL) );

    [[MMShadowManager sharedInstace] beginGeneratingShadows];

    for(int i=0;i<1;i++){
        MMPaperView* paper = [[MMEditablePaperView alloc] initWithFrame:self.view.bounds];
        [stackView addPaperToBottomOfStack:paper];
        paper = [[MMPaperView alloc] initWithFrame:self.view.bounds];
        [stackView addPaperToBottomOfStack:paper];
        paper = [[MMPaperView alloc] initWithFrame:self.view.bounds];
        [stackView addPaperToBottomOfHiddenStack:paper];
        paper = [[MMPaperView alloc] initWithFrame:self.view.bounds];
        [stackView addPaperToBottomOfHiddenStack:paper];
    }
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"cloth.png"]]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationPortrait == interfaceOrientation;
}



@end
