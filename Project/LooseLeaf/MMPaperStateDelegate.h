//
//  MMPaperStateDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/24/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JotViewStateProxy;

@protocol MMPaperStateDelegate <NSObject>

-(void) didLoadState:(JotViewStateProxy*)state;

-(void) didUnloadState:(JotViewStateProxy*)state;

@end
