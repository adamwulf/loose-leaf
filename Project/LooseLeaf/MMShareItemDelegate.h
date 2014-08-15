//
//  MMShareItemDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/8/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MMShareItem;

@protocol MMShareItemDelegate <NSObject>

-(UIImage*) imageToShare;

-(void) didShare:(NSObject<MMShareItem>*)shareItem;

-(void) mayShare:(NSObject<MMShareItem>*)shareItem;

@end
