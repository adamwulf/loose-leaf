//
//  MMOpenInShareItem.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/9/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMOpenInShareItem.h"
#import "MMShareButton.h"
#import "MMShareManager.h"
#import "Mixpanel.h"
#import "Constants.h"
#import "NSThread+BlockAdditions.h"
#import "UIView+Debug.h"
#import "MMShareView.h"
#import "UIColor+Shadow.h"

@implementation MMOpenInShareItem{
    MMShareButton* button;
    MMShareView* sharingOptionsView;
}

@synthesize delegate;
@synthesize isShowingOptionsView;

-(id) init{
    if(self = [super init]){
        button = [[MMShareButton alloc] initWithFrame:CGRectMake(0,0, kWidthOfSidebarButton, kWidthOfSidebarButton)];
        button.arrowColor = [UIColor blackColor];
        button.topBgColor = [UIColor blueShadowColor];
        button.bottomBgColor = [UIColor lightBlueShadowColor];
        button.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:.5];
        
        [button addTarget:self action:@selector(performShareAction) forControlEvents:UIControlEventTouchUpInside];
        
        // arbitrary size, will be resized to fit when it's added to a sidebar
        sharingOptionsView = [[MMShareView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        sharingOptionsView.delegate = self;
    }
    return self;
}

-(void) setIsShowingOptionsView:(BOOL)_isShowingOptionsView{
    isShowingOptionsView = _isShowingOptionsView;
    button.selected = isShowingOptionsView;
    [button setNeedsDisplay];
}

-(MMSidebarButton*) button{
    return button;
}

-(void) performShareAction{
    if(!isShowingOptionsView){
        sharingOptionsView.buttonWidth = self.button.bounds.size.width;
        [sharingOptionsView reset];
        
        NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"temp.png"];
        [UIImagePNGRepresentation(self.delegate.imageToShare) writeToFile:filePath atomically:YES];
        NSURL* fileLocation = [NSURL URLWithString:[@"file://" stringByAppendingString:filePath]];
        [[MMShareManager sharedInstance] beginSharingWithURL:fileLocation];
        [MMShareManager sharedInstance].delegate = self;
    }
}

// called when the menu appears and our button is about to be visible
-(void) willShow{
    // noop
}


// called when our button is no longer visible
-(void) didHide{
    [[MMShareManager sharedInstance] endSharing];
    [MMShareManager sharedInstance].delegate = nil;
    self.isShowingOptionsView = NO;
    self.button.selected = NO;
}

-(BOOL) isAtAllPossible{
    return YES;
}

#pragma mark - Options Menu

// will dispaly buttons to open in any other app
-(UIView*) optionsView{
    return sharingOptionsView;
}

#pragma mark - MMShareViewDelegate

-(void) didShare{
    [delegate performSelector:@selector(didShare) withObject:nil afterDelay:.3];
}

#pragma mark - MMShareManagerDelegate

-(void) allCellsWillLoad{
    [sharingOptionsView allCellsWillLoad];
}

-(void) cellLoaded:(UIView*)cell forIndexPath:(NSIndexPath*)indexPath{
    [sharingOptionsView cellLoaded:cell forIndexPath:indexPath];
}

-(void) allCellsLoaded:(NSArray*)arrayOfAllLoadedButtonIndexes{
    [sharingOptionsView allCellsLoaded:arrayOfAllLoadedButtonIndexes];
}

-(void) sharingHasEnded{
    [self didHide];
    [sharingOptionsView sharingHasEnded];
}


@end
