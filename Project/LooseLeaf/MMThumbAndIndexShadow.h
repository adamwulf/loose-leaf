//
//  MMThumbAndIndexHelper.h
//  LooseLeaf
//
//  Created by Adam Wulf on 1/26/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMThumbAndIndexShadow : NSObject{
    CGRect boundingBox;
    UIBezierPath* openPath;
    UIBezierPath* closedPath;
    
    UIBezierPath* openThumbTipPath;
    UIBezierPath* openIndexFingerTipPath;
    UIBezierPath* closedThumbTipPath;
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
