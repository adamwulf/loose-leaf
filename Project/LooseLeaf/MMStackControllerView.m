//
//  MMStackControllerView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/4/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMStackControllerView.h"
#import "MMStacksManager.h"
#import "MMTextButton.h"
#import "MMPlusButton.h"

@implementation MMStackControllerView

-(void) reloadStackButtons{
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if(![[[MMStacksManager sharedInstance] stackIDs] count]){
        [[MMStacksManager sharedInstance] createStack];
    }
    
    for (int i=0; i<[[[MMStacksManager sharedInstance] stackIDs] count]; i++) {
        MMTextButton* switchToStackButton = [[MMTextButton alloc] initWithFrame:CGRectMake(100 * (i+1), 40, 60, 60) andFont:[UIFont systemFontOfSize:20] andLetter:[NSString stringWithFormat:@"%d", i] andXOffset:0 andYOffset:0];
        switchToStackButton.tag = i;
        [switchToStackButton addTarget:self action:@selector(switchToStackAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:switchToStackButton];
        
        MMTextButton* deleteStackButton = [[MMTextButton alloc] initWithFrame:CGRectMake(100 * (i+1), 90, 60, 60) andFont:[UIFont systemFontOfSize:20] andLetter:@"x" andXOffset:0 andYOffset:0];
        deleteStackButton.tag = i;
        [deleteStackButton addTarget:self action:@selector(deleteStackAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:deleteStackButton];
    }
    
    NSInteger i = [[[MMStacksManager sharedInstance] stackIDs] count];
    MMPlusButton* addStackButton = [[MMPlusButton alloc] initWithFrame:CGRectMake(100 * (i+1), 40, 60, 60)];
    [addStackButton addTarget:self action:@selector(addStack:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:addStackButton];
    
    CGSize cs = CGSizeMake(i*100 + 200, 1);
    
    [self setContentSize:cs];
}

#pragma mark - Actions

-(void) addStack:(UIButton*)button{
    [self.stackDelegate addStack];
}

-(void) switchToStackAction:(UIButton*)sender{
    if(sender.tag < [[[MMStacksManager sharedInstance] stackIDs] count]){
        NSString* stackUUID = [[[MMStacksManager sharedInstance] stackIDs] objectAtIndex:sender.tag];
        [[self stackDelegate] switchToStack:stackUUID];
    }
}

-(void) deleteStackAction:(UIButton*)sender{
    NSString* stackUUID = [[[MMStacksManager sharedInstance] stackIDs] objectAtIndex:sender.tag];
    [self.stackDelegate deleteStack:stackUUID];
}

@end
