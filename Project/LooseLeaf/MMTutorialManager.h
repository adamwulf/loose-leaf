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
@property (readonly) BOOL hasSignedUpForNewsletter;

+ (MMTutorialManager*)sharedInstance;

- (NSArray*)appIntroTutorialSteps;

- (NSArray*)appHelpButtonTutorialSteps;

- (NSArray*)shareTutorialSteps;

- (NSArray*)listViewTutorialSteps;

- (BOOL)hasCompletedStep:(NSString*)stepID;

- (void)didCompleteStep:(NSString*)stepID;

- (void)startWatchingTutorials:(NSArray*)tutorialList;

- (void)pauseWatchingTutorial;

- (void)finishWatchingTutorial;

- (NSInteger)numberOfPendingTutorials:(NSArray*)possiblyPendingTutorials;

- (void)optOutOfNewsletter;

- (void)signUpForNewsletter:(NSString*)email;

@end
