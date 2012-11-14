//
//  SLViewController.m
//  Paper Stack
//
//  Created by Adam Wulf on 6/7/12.
//  Copyright (c) 2012 Skylight, LLC. All rights reserved.
//

#import "SLPaperStackViewController.h"
#import "SLShadowManager.h"
#import "SLPaperManager.h"
#import "SLBackingStoreManager.h"

@interface SLPaperStackViewController ()

@end

@implementation SLPaperStackViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    srand ( time(NULL) );

    [[SLShadowManager sharedInstace] beginGeneratingShadows];
    [SLPaperManager sharedInstace].stackView = stackView;
    [SLPaperManager sharedInstace].idealBounds = self.view.bounds;

    [SLBackingStoreManager sharedInstace].delegate = stackView;
    
    [[SLPaperManager sharedInstace] load];
    [[SLPaperManager sharedInstace] save];
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
