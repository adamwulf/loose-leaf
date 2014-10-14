//
//  MMRotateViewController.m
//  LooseLeaf
//
//  Created by Adam Wulf on 10/13/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMRotateViewController.h"
#import "MMUntouchableView.h"

@implementation MMRotateViewController

-(void) viewDidLoad{
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(100, 100, 200, 40)];
    label.text = @"Rotate View";
    [self.view addSubview:label];
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
