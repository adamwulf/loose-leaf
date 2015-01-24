//
//  MMTwoFingerPanSilhouette.h
//  LooseLeaf
//
//  Created by Adam Wulf on 1/12/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMTwoFingerPanShadow : NSObject{
    CGRect boundingBox;
    UIBezierPath* openPath;
    UIBezierPath* closedPath;

    UIBezierPath* openMiddleFingerTipPath;
    UIBezierPath* openIndexFingerTipPath;
    UIBezierPath* closedMiddleFingerTipPath;
    UIBezierPath* closedIndexFingerTipPath;
}

- (instancetype)init NS_UNAVAILABLE;
-(id) initForRightHand:(BOOL)isRight;

-(UIBezierPath*) pathForTouches:(NSArray*)touches;
-(CGPoint) locationOfIndexFingerInPathBounds;

-(void) setFingerDistance:(CGFloat)distance;

#pragma mark - Debug

-(void) openTo:(CGFloat)openPercent;

@end
