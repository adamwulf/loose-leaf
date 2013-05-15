//
//  MMShadowManager.h
//  Loose Leaf
//
//  Created by Adam Wulf on 6/23/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MMShadowManager : NSObject{
    NSMutableDictionary* shadowPathCache;
    UIBezierPath* unitShadowPath;
}

+(MMShadowManager*) sharedInstace;

-(void) beginGeneratingShadows;
-(CGPathRef) getShadowForSize:(CGSize)size;

@end
