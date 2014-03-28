//
//  MMSidebarImagePicker.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/27/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMSidebarButton.h"
#import "MMSidebarImagePickerDelegate.h"

#define kBounceWidth 10.0


@interface MMSidebarImagePicker : UIView{
    __weak NSObject<MMSidebarImagePickerDelegate>* delegate;
}

@property (nonatomic, weak) NSObject<MMSidebarImagePickerDelegate>* delegate;

- (id)initWithFrame:(CGRect)frame forButton:(MMSidebarButton*)button;

- (void)bounceAnimationForButtonWithDuration:(CGFloat)duration;

@end
