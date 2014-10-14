//
//  MMRotateViewController.m
//  LooseLeaf
//
//  Created by Adam Wulf on 10/13/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMRotateViewController.h"
#import "MMUntouchableView.h"
#import "MMPresentationWindow.h"

@implementation MMRotateViewController

-(id) initWithWindow:(MMPresentationWindow*)_window{
    if(self = [super init]){
        window = _window;
    }
    return self;
}

-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    window.shouldRespectKeyWindowRequest = NO;
}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    window.shouldRespectKeyWindowRequest = YES;
}

-(void) viewDidLoad{
//    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(100, 100, 200, 40)];
//    label.text = @"Rotate View";
//    [self.view addSubview:label];
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
