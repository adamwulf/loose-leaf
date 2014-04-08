//
//  UIGestureRecognizer+GestureDebug.h
//  LooseLeaf
//
//  Created by Adam Wulf on 7/31/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIGestureRecognizer (GestureDebug)

-(void) say:(NSString*)prefix ISee:(NSSet*)touches;

@end
