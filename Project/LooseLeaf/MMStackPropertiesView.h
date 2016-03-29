//
//  MMStackPropertiesView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/28/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMRoundedSquareView.h"

@interface MMStackPropertiesView : MMRoundedSquareView

-(instancetype) initWithFrame:(CGRect)frame NS_UNAVAILABLE;
-(instancetype) initWithFrame:(CGRect)frame andStackUUID:(NSString*)stackUUID;

@end
