//
//  MMStacksManager.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/6/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMStacksManager : NSObject

+(MMStacksManager*) sharedInstance;

-(NSString*) createStack;

-(void) deleteStack:(NSString*)stackUUID;

-(NSArray*)stackIDs;

@end
