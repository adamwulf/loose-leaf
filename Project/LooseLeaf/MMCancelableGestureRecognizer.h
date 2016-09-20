//
//  MMCancelableGestureRecognizer.h
//  LooseLeaf
//
//  Created by Adam Wulf on 6/13/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MMCancelableGestureRecognizer : UIGestureRecognizer <UIGestureRecognizerDelegate>

- (void)cancel;

@end
