//
//  MMStackControllerView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/4/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMStackControllerViewDelegate.h"

@interface MMStackControllerView : UIScrollView

@property (nonatomic, weak) NSObject<MMStackControllerViewDelegate>* stackDelegate;

-(void) reloadStackButtons;

@end
