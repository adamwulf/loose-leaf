//
//  MMTwoFingerPanSilhouette.h
//  LooseLeaf
//
//  Created by Adam Wulf on 1/12/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMTwoFingerPanSilhouette : NSObject

@property (readonly) CAShapeLayer* handLayer;

-(void) openTo:(CGFloat)openPercent;


@end
