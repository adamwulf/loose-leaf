//
//  MMFeedbackViewController.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/26/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MMFeedbackViewController : UIViewController

- (instancetype)initWithCompletionBlock:(void (^)())_completionBlock;

@end
