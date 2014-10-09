//
//  NSArray+Extras.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/26/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Extras)

-(NSArray*) reversedArray;

-(NSArray*) arrayByRemovingObject:(id)obj;

-(NSArray*) shuffledArray;

-(NSSet*) asSet;

@end

@interface NSMutableArray (Extras)

-(void) shuffle;

@end
