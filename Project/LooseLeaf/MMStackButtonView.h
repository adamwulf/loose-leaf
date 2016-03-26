//
//  MMStackButtonView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/26/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMStackButtonViewDelegate.h"

@interface MMStackButtonView : UIView

@property (nonatomic, weak) NSObject<MMStackButtonViewDelegate>* delegate;

-(instancetype) initWithFrame:(CGRect)frame NS_UNAVAILABLE;

-(instancetype) initWithFrame:(CGRect)frame andStackUUID:(NSString*)stackUUID;

-(void) loadThumb;

@end
