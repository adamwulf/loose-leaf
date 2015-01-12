//
//  MMViewController.h
//  Loose Leaf
//
//  Created by Adam Wulf on 6/7/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMScrapPaperStackView.h"
#import <Crashlytics/Crashlytics.h>

@interface MMLooseLeafViewController : UIViewController{
    MMScrapPaperStackView* stackView;
}


@property (readonly) MMScrapPaperStackView* stackView;

-(void) importFileFrom:(NSURL*)url fromApp:(NSString*)sourceApplication;

-(void) willResignActive;

@end
