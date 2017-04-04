//
//  MMBackgroundStyleContainerViewDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 4/3/17.
//  Copyright © 2017 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMSlidingSidebarContainerViewDelegate.h"

@protocol MMBackgroundStyleContainerViewDelegate <NSObject>

-(NSString*) currentBackgroundStyleType;

-(void) setCurrentBackgroundStyleType:(NSString*)currentBackgroundStyle;

@end
