//
//  NSMutableSet+Extras.h
//  jotuiexample
//
//  Created by Adam Wulf on 6/19/12.
//  Copyright (c) 2012 Adonit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableSet (Extras)

-(void) addObjectsInSet:(NSSet*)set;

-(void) removeObjectsInSet:(NSSet*)set;

-(NSSet*) setByRemovingObject:(id)obj;

@end


@interface NSMutableOrderedSet (Extras)

-(void) addObjectsInOrderedSet:(NSOrderedSet*)set;

-(void) addObjectsInSet:(NSSet*)set;

-(void) removeObjectsInSet:(NSSet*)set;

-(NSSet*) setByRemovingObject:(id)obj;

@end
