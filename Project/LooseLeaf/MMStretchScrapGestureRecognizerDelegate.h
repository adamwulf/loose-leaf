//
//  MMStretchScrapGestureRecognizerDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/10/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Constants.h"
#import "MMPanGestureDelegate.h"

@protocol MMStretchScrapGestureRecognizerDelegate <MMPanGestureDelegate>

-(BOOL) panScrapRequiresLongPress;

-(NSArray*) scraps;


-(void) beginStretchForScrap:(MMScrapView*)scrap;

-(void) endStretchForScrap:(MMScrapView*)scrap;

@end
