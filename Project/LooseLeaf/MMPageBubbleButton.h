//
//  MMPageBubbleButton.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/29/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMBubbleButton.h"
#import "MMEditablePaperView.h"


@interface MMPageBubbleButton : UIButton <MMBubbleButton>

@property (nonatomic) MMEditablePaperView* view; // from MMBubbleButton

@end
