//
//  MMCloudKitOptionsView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/20/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCloudKitOptionsView.h"
#import "UIView+Debug.h"
#import "Constants.h"

@implementation MMCloudKitOptionsView{
    UILabel* cloudKitLabel;
}

-(id) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        CGRect lblFr = self.bounds;
        lblFr.origin.y = kWidthOfSidebarButtonBuffer;
        
        cloudKitLabel = [[UILabel alloc] initWithFrame:lblFr];
        cloudKitLabel.backgroundColor = [UIColor clearColor];
        cloudKitLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        cloudKitLabel.text = @"cloudkit!";
        cloudKitLabel.numberOfLines = 0;
        [self addSubview:cloudKitLabel];
        
        [MMCloudKitManager sharedManager].delegate = self;
        
        [self updateInterfaceBasedOniCloudStatus];
    }
    return self;
}

#pragma mark - MMShareOptionsView

-(void) show{
    [super show];
    [self updateInterfaceBasedOniCloudStatus];
}

#pragma mark - CloudKit UI

-(void) updateInterfaceBasedOniCloudStatus{
    NSString* cloudKitInfo = [[MMCloudKitManager sharedManager] description];
    
    cloudKitLabel.text = cloudKitInfo;
    [cloudKitLabel sizeToFit];
    
    CGRect fr = cloudKitLabel.frame;
    fr.origin.y = kWidthOfSidebarButtonBuffer;
    fr.size.width = self.bounds.size.width;
    cloudKitLabel.frame = fr;
    
    fr = self.frame;
    fr.size.height = cloudKitLabel.bounds.size.height + cloudKitLabel.frame.origin.y;
    self.frame = fr;
}

#pragma mark - MMCloudKitManagerDelegate

-(void) cloudKitDidError:(NSError *)err{
    NSLog(@"cloudkit error: %@", err);
    [self updateInterfaceBasedOniCloudStatus];
}

-(void) cloudKitStatusIsLoading{
    NSLog(@"cloudkit is loading...");
    [self updateInterfaceBasedOniCloudStatus];
}

-(void) cloudKitIsUnavailableForThisUser{
    NSLog(@"CloudKit is unavailable!");
    [self updateInterfaceBasedOniCloudStatus];
}

-(void) cloudKitPermissionIsUnknownForThisUser{
    NSLog(@"unknown cloudkit permission. need to ask the user");
    [self updateInterfaceBasedOniCloudStatus];
}

@end
