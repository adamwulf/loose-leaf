//
//  MMReleaseNotesButtonPrompt.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/5/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MMReleaseNotesButtonPrompt : UIView

@property (nonatomic, strong) NSString* prompt;
@property (nonatomic, strong) NSString* confirmAnswer;
@property (nonatomic, strong) NSString* denyAnswer;

@property (nonatomic, strong) void (^confirmBlock)();
@property (nonatomic, strong) void (^denyBlock)();

@end
