//
//  MMCloudKeyButton.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/9/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMCloudKeyButton : UIButton

@property (nonatomic, readonly) BOOL isShowingKey;

-(void) setupTimer;

-(void) tearDownTimer;

-(void) flipImmediatelyToCloud;

-(void) flipAnimatedToKeyWithCompletion:(void (^)())completion;

-(void) animateToBrokenCloud;

@end
