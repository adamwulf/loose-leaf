//
//  NSMutableSet+Extras.h
//  Loose Leaf
//
//  Created by Adam Wulf on 6/19/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableSet (Extras)

-(void) removeObjectsInSet:(NSSet*)set;

-(NSSet*) setByRemovingObject:(id)obj;

@end


@interface NSMutableOrderedSet (Extras)

-(void) removeObjectsInSet:(NSSet*)set;

-(NSSet*) setByRemovingObject:(id)obj;

@end
