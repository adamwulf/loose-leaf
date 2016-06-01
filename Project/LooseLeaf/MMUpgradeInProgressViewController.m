//
//  MMUpgradeInProgressViewController.m
//  LooseLeaf
//
//  Created by Adam Wulf on 5/31/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMUpgradeInProgressViewController.h"
#import "Constants.h"

@interface MMUpgradeInProgressViewController ()

@end

@implementation MMUpgradeInProgressViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGRectGetMidPoint(self.view.bounds);
    spinner.autoresizingMask = UIViewAutoresizingFlexibleAllMargins;
    
    [self.view addSubview:spinner];
    
    UILabel* upgradingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    upgradingLabel.text = @"Upgrading...";
    [upgradingLabel sizeToFit];
    
    CGPoint p = CGRectGetMidPoint(self.view.bounds);
    p.y += (CGRectGetHeight(spinner.bounds) + CGRectGetHeight(upgradingLabel.bounds)) / 2 + 2;
    upgradingLabel.center = p;
    upgradingLabel.autoresizingMask = UIViewAutoresizingFlexibleAllMargins;

    [self.view addSubview:upgradingLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
