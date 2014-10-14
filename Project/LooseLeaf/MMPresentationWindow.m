//
//  MMPresentationWindow.m
//  LooseLeaf
//
//  Created by Adam Wulf on 10/13/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMPresentationWindow.h"
#import "MMAppDelegate.h"
#import "UIView+Debug.h"
#import "MMRotateViewController.h"

@implementation MMPresentationWindow

@synthesize shouldRespectKeyWindowRequest;

-(id) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        self.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0];
//        [self showDebugBorder];
        // Override point for customization after application launch.
        self.rootViewController = [[MMRotateViewController alloc] initWithWindow:self];
        self.alpha = 0;
    }
    return self;
}

-(void) makeKeyAndVisible{
    if(shouldRespectKeyWindowRequest){
        NSLog(@"presentation window is key");
        [super makeKeyAndVisible];
        self.alpha = 1;
    }else{
        NSLog(@"presentation window ignored key window request");
    }
}

-(void) resignKeyWindow{
    NSLog(@"presentation window resigned");
    self.alpha = 0;
}

-(void) didAddSubview:(UIView *)subview{
    NSLog(@"adding subview: %@", subview);
    NSLog(@" with subviews: %@", subview.subviews);
    [super didAddSubview:subview];
    if([self.subviews count] > 1){
        [self makeKeyAndVisible];
    }
}

-(void) willRemoveSubview:(UIView *)subview{
    [super willRemoveSubview:subview];
    // if we remove a subview, and we're left with only
    // one view (our root view controller), then the
    // popover has been dismissed. close out the window
    if([self.subviews count] - 1 == 1){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self killPresentationWindow];
        });
    }
}

-(void) killPresentationWindow{
    if([self.subviews count] == 1){
        if([UIApplication sharedApplication].keyWindow == self){
            NSLog(@"killing presentation window");
            MMAppDelegate* appDelegate = (MMAppDelegate*)[[UIApplication sharedApplication] delegate];
            [appDelegate.window makeKeyAndVisible];
        }
    }
}

-(void) dealloc{
    NSLog(@"dealloc window");
}

@end
