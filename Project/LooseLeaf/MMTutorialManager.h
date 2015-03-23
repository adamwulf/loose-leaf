//
//  MMTutorialManager.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/21/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMTutorialManager : NSObject

@property (readonly) BOOL isWatchingTutorial;
@property (readonly) BOOL hasFinishedTutorial;

+(MMTutorialManager*) sharedInstance;

-(NSArray*) tutorialSteps;

-(BOOL) hasCompletedStep:(NSString*)stepID;

-(void) didCompleteStep:(NSString*)stepID;

-(void) startWatchingTutorial;

-(void) pauseWatchingTutorial;

-(void) finishWatchingTutorial;

-(NSInteger) numberOfPendingTutorials;

@end
