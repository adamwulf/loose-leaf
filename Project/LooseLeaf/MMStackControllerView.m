//
//  MMStackControllerView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/4/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMStackControllerView.h"
#import "MMStacksManager.h"
#import "MMStackButtonView.h"
#import "MMTextButton.h"
#import "MMPlusButton.h"
#import "UIView+Debug.h"

@interface MMStackControllerView ()<MMStackButtonViewDelegate>

@end

@implementation MMStackControllerView

-(void) reloadStackButtons{
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if(![[[MMStacksManager sharedInstance] stackIDs] count]){
        [[MMStacksManager sharedInstance] createStack];
    }
    
    for (int i=0; i<[[[MMStacksManager sharedInstance] stackIDs] count]; i++) {
        NSString* stackUUID = [[[MMStacksManager sharedInstance] stackIDs] objectAtIndex:i];
        MMStackButtonView* stackButton = [[MMStackButtonView alloc] initWithFrame:CGRectMake(200 * i, 0, 200, CGRectGetHeight(self.bounds)) andStackUUID:stackUUID];
        
        [stackButton loadThumb];
        [stackButton setDelegate:self];
        
        [self addSubview:stackButton];
    }
    
    NSInteger i = [[[MMStacksManager sharedInstance] stackIDs] count];
    MMPlusButton* addStackButton = [[MMPlusButton alloc] initWithFrame:CGRectMake(200 * i + 70, 40, 60, 60)];
    [addStackButton addTarget:self action:@selector(addStack:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:addStackButton];
    
    CGSize cs = CGSizeMake(i*200 + 200, 1);
    
    [self setContentSize:cs];
}

#pragma mark - Actions

-(void) addStack:(UIButton*)button{
    [self.stackDelegate addStack];
}

-(void) deleteStackAction:(UIButton*)sender{
    NSString* stackUUID = [[[MMStacksManager sharedInstance] stackIDs] objectAtIndex:sender.tag];
    [self.stackDelegate deleteStack:stackUUID];
}

#pragma mark - MMStackButtonViewDelegate

-(void) switchToStackAction:(NSString*)stackUUID{
    [[self stackDelegate] switchToStack:stackUUID];
}

@end
