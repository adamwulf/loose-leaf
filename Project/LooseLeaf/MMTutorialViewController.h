//
//  MMTutorialViewController.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/5/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MMTutorialViewController : UIViewController

- (instancetype)initWithTutorials:(NSArray*)tutorialList andCompletionBlock:(void (^)())completionBlock;

- (void)closeTutorials;

@end
