//
//  MMCamViewDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 4/12/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MMCamViewDelegate <NSObject>

-(void) didTakePicture:(UIImage*)img;

@end
