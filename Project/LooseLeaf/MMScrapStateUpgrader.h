//
//  MMScrapStateUpgrader.h
//  LooseLeaf
//
//  Created by Adam Wulf on 6/1/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMScrapStateUpgrader : NSObject

-(instancetype) initWithPagesPath:(NSString*)pagesPath;

-(void) upgradeWithCompletionBlock:(void(^)())onComplete;

@end
