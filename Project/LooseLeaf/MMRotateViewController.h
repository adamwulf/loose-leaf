//
//  MMRotateViewController.h
//  LooseLeaf
//
//  Created by Adam Wulf on 10/13/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MMPresentationWindow;

@interface MMRotateViewController : UIViewController{
    MMPresentationWindow* window;
}

-(id) initWithWindow:(MMPresentationWindow*)_window;

@end
