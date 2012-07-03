//
//  NSMutableSet+Extras.h
//  Paper Stack
//
//  Created by Adam Wulf on 6/19/12.
//  Copyright (c) 2012 Visere. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableSet (Extras)

-(void) removeObjectsInSet:(NSSet*)set;

-(NSSet*) setByRemovingObject:(id)obj;

@end
