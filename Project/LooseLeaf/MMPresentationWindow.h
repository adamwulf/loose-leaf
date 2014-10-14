//
//  MMPresentationWindow.h
//  LooseLeaf
//
//  Created by Adam Wulf on 10/13/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMWindow.h"

@interface MMPresentationWindow : MMWindow

@property (nonatomic, assign) BOOL shouldRespectKeyWindowRequest;

-(void) killPresentationWindow;

@end
