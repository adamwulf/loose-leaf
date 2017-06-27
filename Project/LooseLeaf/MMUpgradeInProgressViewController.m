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


@implementation MMUpgradeInProgressViewController {
    UIProgressView* progressBar;
    UIActivityIndicatorView* spinner;
    UILabel* upgradingLabel;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGRectGetMidPoint(self.view.bounds);
    spinner.autoresizingMask = UIViewAutoresizingFlexibleAllMargins;
    [spinner startAnimating];

    [self.view addSubview:spinner];

    CGPoint p = CGRectGetMidPoint(self.view.bounds);

    progressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    CGRect progressBounds = progressBar.bounds;
    progressBounds.size.width = 200;
    [progressBar setBounds:progressBounds];
    progressBar.center = p;
    [progressBar setHidden:YES];
    [self.view addSubview:progressBar];

    upgradingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    upgradingLabel.text = NSLocalizedString(@"Upgrading...", @"Upgrading...");
    [upgradingLabel sizeToFit];

    p.y += (CGRectGetHeight(spinner.bounds) + CGRectGetHeight(upgradingLabel.bounds)) / 2 + 2;
    upgradingLabel.center = p;
    upgradingLabel.autoresizingMask = UIViewAutoresizingFlexibleAllMargins;

    [self.view addSubview:upgradingLabel];
}

- (void)setProgress:(CGFloat)progress {
    [spinner stopAnimating];
    [progressBar setHidden:NO];
    [progressBar setProgress:progress];

    if (progress >= 1.0) {
        [progressBar setHidden:YES];
        upgradingLabel.text = NSLocalizedString(@"Upgrade Complete.", @"Upgrade Complete.");

        CGPoint location = upgradingLabel.center;
        [upgradingLabel sizeToFit];
        upgradingLabel.center = location;
    }
}

@end
