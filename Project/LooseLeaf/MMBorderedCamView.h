//
//  MMBorderedCamView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 4/11/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMCamViewDelegate.h"

@interface MMBorderedCamView : UIView

@property (nonatomic, weak) NSObject<MMCamViewDelegate>* delegate;
@property (nonatomic, assign) CGFloat rotation;

-(void) changeCamera;

@end
