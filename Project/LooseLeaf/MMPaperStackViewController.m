//
//  MMViewController.m
//  Loose Leaf
//
//  Created by Adam Wulf on 6/7/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "MMPaperStackViewController.h"
#import "MMShadowManager.h"

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
        MMPaperView* paper = [[MMPaperView alloc] initWithFrame:self.view.bounds];
        [stackView addPaperToBottomOfStack:paper];
        paper = [[MMPaperView alloc] initWithFrame:self.view.bounds];
        [stackView addPaperToBottomOfStack:paper];

        paper = [[MMPaperView alloc] initWithFrame:self.view.bounds];
        [stackView addPaperToBottomOfHiddenStack:paper];
        paper = [[MMPaperView alloc] initWithFrame:self.view.bounds];
        [stackView addPaperToBottomOfHiddenStack:paper];
    }

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [stackView release];
    stackView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationPortrait == interfaceOrientation;
}



@end
