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


@implementation MMLooseLeafViewController

- (id)init{
    if(self = [super init]){
        // Do any additional setup after loading the view, typically from a nib.
        srand ( time(NULL) );
        [[MMShadowManager sharedInstace] beginGeneratingShadows];
    
        self.view.opaque = YES;
        
        stackView = [[MMEditablePaperStackView alloc] initWithFrame:self.view.frame];
        stackView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:stackView];
        
        [stackView loadStacksFromDisk];
        
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"cloth.png"]]];
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationPortrait == interfaceOrientation;
}

@end
