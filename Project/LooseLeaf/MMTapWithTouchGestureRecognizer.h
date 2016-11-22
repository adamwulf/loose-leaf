//
//  MMTapWithTouchGestureRecognizer.h
//  LooseLeaf
//
//  Created by Adam Wulf on 11/21/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MMTapWithTouchGestureRecognizer : UITapGestureRecognizer

- (NSArray<UITouch*>*)touches;

@end
