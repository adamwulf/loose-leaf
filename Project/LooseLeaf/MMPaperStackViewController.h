//
//  MMViewController.h
//  Loose Leaf
//
//  Created by Adam Wulf on 6/7/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMEditablePaperStackView.h"

@interface MMLooseLeafViewController : UIViewController{
    IBOutlet MMEditablePaperStackView* stackView;
}

@end
