//
//  MMStretchHelper.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/16/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface MMStretchHelper : NSObject

+(Quadrilateral) adjustedQuad:(Quadrilateral)a by:(CGPoint)p;

+(void) sortTouchesClockwise:(NSMutableOrderedSet<UITouch*>*)touches;

+(Quadrilateral) getNormalizedRawQuadFrom:(NSOrderedSet<UITouch*>*)touches inView:(UIView*)view;

+(Quadrilateral) getQuadFrom:(NSOrderedSet<UITouch*>*)touches inView:(UIView*)view;

+ (CATransform3D)transformQuadrilateral:(Quadrilateral)origin toQuadrilateral:(Quadrilateral)destination;

@end
