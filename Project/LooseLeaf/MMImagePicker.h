//
//  MMImagePicker.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/27/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMSidebarButton.h"
#import "MMSidebarImagePicker.h"
#import "MMSidebarImagePickerDelegate.h"

@interface MMImagePicker : UIView<MMSidebarImagePickerDelegate>

- (id)initWithFrame:(CGRect)frame forButton:(MMSidebarButton*)button;

-(void) hide:(BOOL)animated;

-(void) show:(BOOL)animated;


@end
