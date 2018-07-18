//
//  MMFeedbackManager.h
//  LooseLeaf
//
//  Created by Adam Wulf on 7/18/18.
//  Copyright © 2018 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MMFeedbackManager : NSObject

+ (MMFeedbackManager*)sharedInstance;

- (void)sendFeedback:(NSString*)feedback;

- (void)sendFeedback:(NSString*)feedback fromEmail:(NSString*)email;

@end
