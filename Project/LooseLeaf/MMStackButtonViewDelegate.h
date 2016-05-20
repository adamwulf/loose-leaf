//
//  MMStackButtonViewDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/26/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MMStackButtonViewDelegate <NSObject>

-(void) switchToStackAction:(NSString*)stackUUID;

-(void) didTapNameForStack:(NSString*)stackUUID;

@end
