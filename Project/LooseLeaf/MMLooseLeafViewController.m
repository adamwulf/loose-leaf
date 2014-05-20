//
//  MMViewController.m
//  Loose Leaf
//
//  Created by Adam Wulf on 6/7/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "MMLooseLeafViewController.h"
#import "MMShadowManager.h"
#import "MMEditablePaperView.h"
#import "TestFlight.h"
#import "MMDebugDrawView.h"
#import "Mixpanel.h"

@implementation MMLooseLeafViewController

- (id)init{
    if(self = [super init]){
        
//        [NSThread performBlockInBackground:^{
//            [TestFlight takeOff:kTestflightAppToken];
//            [TestFlight setOptions:@{ TFOptionLogToConsole : @NO }];
//            [TestFlight setOptions:@{ TFOptionLogToSTDERR : @NO }];
//            [TestFlight setOptions:@{ TFOptionLogOnCheckpoint : @NO }];
//            [TestFlight setOptions:@{ TFOptionSessionKeepAliveTimeout : @60 }];
//        }];

        // Do any additional setup after loading the view, typically from a nib.
        srand ((uint) time(NULL) );
        [[MMShadowManager sharedInstace] beginGeneratingShadows];
    
        self.view.opaque = YES;
        
        stackView = [[MMScrapPaperStackView alloc] initWithFrame:self.view.frame];
        stackView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:stackView];
        
        [stackView loadStacksFromDisk];
        
        [[[Mixpanel sharedInstance] people] set:kMPNumberOfPages
                                             to:@([stackView.visibleStackHolder.subviews count] + [stackView.hiddenStackHolder.subviews count])];

        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"cloth.png"]]];
        
//        [self.view addSubview:[MMDebugDrawView sharedInstace]];
        
    }
    return self;
}

-(void) printKeys:(NSDictionary*)dict atlevel:(NSInteger)level{
    NSString* space = @"";
    for(int i=0;i<level;i++){
        space = [space stringByAppendingString:@" "];
    }
    for(NSString* key in [dict allKeys]){
        
        id obj = [dict objectForKey:key];
        if([obj isKindOfClass:[NSDictionary class]]){
            [self printKeys:obj atlevel:level+1];
        }else{
            if([obj isKindOfClass:[NSArray class]]){
                NSLog(@"%@ %@ - %@ [%lu]", space, key, [obj class], (unsigned long)[obj count]);
            }else{
                NSLog(@"%@ %@ - %@", space, key, [obj class]);
            }
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationPortrait == interfaceOrientation;
}

@end
