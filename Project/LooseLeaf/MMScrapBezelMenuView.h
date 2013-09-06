//
//  MMScrapBezelMenuView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/5/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMScrapBezelMenuViewDelegate.h"

@interface MMScrapBezelMenuView : UIView{
    __weak NSObject<MMScrapBezelMenuViewDelegate>* delegate;
}

@property (nonatomic, weak) NSObject<MMScrapBezelMenuViewDelegate>* delegate;

-(void) prepareMenu;

-(void) flashScrollIndicators;

@end
