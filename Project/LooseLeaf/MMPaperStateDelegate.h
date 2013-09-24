//
//  MMPaperStateDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/24/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MMPaperState;

@protocol MMPaperStateDelegate <NSObject>

-(BOOL) didLoadState:(MMPaperState*)state;

-(BOOL) didUnloadState:(MMPaperState*)state;

-(BOOL) didSaveState:(MMPaperState*)state;

@end
