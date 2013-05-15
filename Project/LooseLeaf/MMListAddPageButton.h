//
//  MMListAddPageIcon.h
//  Loose Leaf
//
//  Created by Adam Wulf on 9/4/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMListAddPageButtonDelegate.h"

@interface MMListAddPageButton : UIView{
    NSObject<MMListAddPageButtonDelegate>* delegate;
}

@property (nonatomic, assign) NSObject<MMListAddPageButtonDelegate>* delegate;


@end
