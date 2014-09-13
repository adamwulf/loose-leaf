//
//  MMShareView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/10/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMUntouchableView.h"
#import "MMOpenInAppManagerDelegate.h"
#import "MMOpenInAppOptionsViewDelegate.h"
#import "MMShareOptionsView.h"


@interface MMOpenInAppOptionsView : MMShareOptionsView<MMOpenInAppManagerDelegate>

@property (nonatomic) CGFloat buttonWidth;
@property (weak) NSObject<MMOpenInAppOptionsViewDelegate>* delegate;

-(void) reset;

@end
