//
//  MMTrashManager.h
//  LooseLeaf
//
//  Created by Adam Wulf on 7/26/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMTrashManager : NSObject

+(MMTrashManager*) sharedInstace;

-(void) deleteScrap:(NSString*)scrapUUID inPage:(NSString*)pageUUID;

@end
