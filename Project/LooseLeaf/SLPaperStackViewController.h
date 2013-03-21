//
//  SLViewController.h
//  Paper Stack
//
//  Created by Adam Wulf on 6/7/12.
//  Copyright (c) 2012 Skylight, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLPaperStackView.h"
#import "SLPaperView.h"

@interface MSLooseLeafViewController : UIViewController{
    IBOutlet SLPaperStackView* stackView;
}

@end
