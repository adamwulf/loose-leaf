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
#import "TestFlight.h"

@implementation MMLooseLeafViewController

- (id)init{
    if(self = [super init]){
        
//        [NSThread performBlockInBackground:^{
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wdeprecated-declarations"
//#pragma clang diagnostic ignored "-Wundeclared-selector"
//            if([[UIDevice currentDevice] respondsToSelector:@selector(uniqueIdentifier)]){
//                [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] performSelector:@selector(uniqueIdentifier)]];
//            }
//#pragma clang diagnostic pop
//            [TestFlight takeOff:kTestflightAppToken];
//            [TestFlight setOptions:@{ TFOptionLogToConsole : @NO }];
//            [TestFlight setOptions:@{ TFOptionLogToSTDERR : @NO }];
//            [TestFlight setOptions:@{ TFOptionLogOnCheckpoint : @NO }];
//            [TestFlight setOptions:@{ TFOptionSessionKeepAliveTimeout : @60 }];
//        }];

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
