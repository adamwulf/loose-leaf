//
//  MMViewController.h
//  Loose Leaf
//
//  Created by Adam Wulf on 6/7/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMTutorialStackView.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@interface MMLooseLeafViewController : UIViewController{
    MMTutorialStackView* stackView;
}

-(void) importFileFrom:(NSURL*)url fromApp:(NSString*)sourceApplication;

-(void) willResignActive;

-(void) didEnterBackground;

@end
