//
//  SLViewController.m
//  Paper Stack
//
//  Created by Adam Wulf on 6/7/12.
//  Copyright (c) 2012 Skylight, LLC. All rights reserved.
//

#import "SLPaperStackViewController.h"

@interface SLPaperStackViewController ()

@end

@implementation SLPaperStackViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    srand ( time(NULL) );

    for(int i=0;i<10;i++){
        SLPaperView* paper = [[SLPaperView alloc] initWithFrame:self.view.bounds];
        [stackView addPaperToBottomOfStack:paper];
        paper = [[SLPaperView alloc] initWithFrame:self.view.bounds];
        [stackView addPaperToBottomOfStack:paper];
        paper = [[SLPaperView alloc] initWithFrame:self.view.bounds];
        [stackView addPaperToBottomOfStack:paper];
        paper = [[SLPaperView alloc] initWithFrame:self.view.bounds];
        [stackView addPaperToBottomOfStack:paper];
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
    return YES;
}

@end
