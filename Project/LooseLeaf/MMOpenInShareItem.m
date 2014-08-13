//
//  MMOpenInShareItem.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/9/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMOpenInShareItem.h"
#import "MMImageViewButton.h"
#import "MMShareManager.h"
#import "Mixpanel.h"
#import "Constants.h"
#import "NSThread+BlockAdditions.h"
#import "UIView+Debug.h"
#import "MMShareView.h"

@implementation MMOpenInShareItem{
    MMImageViewButton* button;
    UIView* sharingOptionsView;
}

@synthesize delegate;

-(id) init{
    if(self = [super init]){
        button = [[MMImageViewButton alloc] initWithFrame:CGRectMake(0,0, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        [button setImage:[UIImage imageNamed:@"photoalbum"]];
        button.greyscale = NO;
        
        [button addTarget:self action:@selector(performShareAction) forControlEvents:UIControlEventTouchUpInside];
        
        // arbitrary size, will be resized to fit when it's added to a sidebar
        sharingOptionsView = [[MMShareView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        sharingOptionsView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:.5];
        [sharingOptionsView showDebugBorder];
    }
    return self;
}

-(MMSidebarButton*) button{
    return button;
}

-(void) performShareAction{
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"temp.png"];
    
    [UIImagePNGRepresentation(self.delegate.imageToShare) writeToFile:filePath atomically:YES];
    NSURL* fileLocation = [NSURL URLWithString:[@"file://" stringByAppendingString:filePath]];
    
    [[MMShareManager sharedInstace] beginSharingWithURL:fileLocation];
    
    for(int i=1;i<5;i++){
        [[NSThread mainThread] performBlock:^{
            NSUInteger numberOfItems = [[MMShareManager sharedInstace] numberOfShareTargets];
            CGRect fr = sharingOptionsView.frame;
            fr.size.height = numberOfItems * (kWidthOfSidebarButton + kWidthOfSidebarButtonBuffer);
            sharingOptionsView.frame = fr;
            [sharingOptionsView setNeedsDisplay];
        } afterDelay:i];
    }
}

-(BOOL) isAtAllPossible{
    return YES;
}

#pragma mark - Options Menu

// will dispaly buttons to open in any other app
-(UIView*) optionsView{
    return sharingOptionsView;
}

@end
