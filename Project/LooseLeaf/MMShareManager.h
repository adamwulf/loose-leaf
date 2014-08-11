//
//  MMShareManager.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/10/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMShareManager : NSObject

-(NSArray*) allViews;

+(MMShareManager*) sharedInstace;

-(void) addCollectionView:(UICollectionView*)view;

-(void) registerDismissView:(UIView*)dismissView;

-(void) reset;

@end
