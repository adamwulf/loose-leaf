//
//  MMStackControllerViewDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/25/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MMStackControllerViewDelegate <NSObject>

-(void) addStack;

-(void) switchToStack:(NSString*)stackUUID;

-(void) deleteStack:(NSString*)stackUUID;

-(void) didTapNameForStack:(NSString*)stackUUID;

@end
