//
//  MMSidebarImagePickerDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/27/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MMSlidingSidebarContainerViewDelegate <NSObject>

-(void) sidebarCloseButtonWasTapped;

-(void) sidebarWillShow;

-(void) sidebarWillHide;

-(UIView*) viewForBlur;

-(UIImage*) imageForBlur;

@end
