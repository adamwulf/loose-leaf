//
//  MMShareSidebarContainerView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/8/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMShareSidebarContainerView.h"
#import "MMImageViewButton.h"
#import "MMCloudKitShareItem.h"
#import "MMEmailShareItem.h"
#import "MMTextShareItem.h"
#import "MMTwitterShareItem.h"
#import "MMFacebookShareItem.h"
#import "MMSinaWeiboShareItem.h"
#import "MMTencentWeiboShareItem.h"
#import "MMPhotoAlbumShareItem.h"
#import "MMImgurShareItem.h"
#import "MMPrintShareItem.h"
#import "MMOpenInAppShareItem.h"
#import "MMCopyShareItem.h"
#import "MMPinterestShareItem.h"
#import "NSThread+BlockAdditions.h"
#import "MMShareOptionsView.h"
#import "MMRotationManager.h"
#import "Constants.h"
#import "UIView+Debug.h"
#import "MMLargeTutorialSidebarButton.h"
#import "MMTutorialManager.h"

@implementation MMShareSidebarContainerView{
    UIView* sharingContentView;
    UIView* buttonView;
    MMShareOptionsView* activeOptionsView;
    NSMutableArray* shareItems;
    
    MMCloudKitShareItem* cloudKitShareItem;
}

@synthesize shareDelegate;

- (id)initWithFrame:(CGRect)frame forButton:(MMSidebarButton *)_button animateFromLeft:(BOOL)fromLeft{
    if (self = [super initWithFrame:frame forButton:_button animateFromLeft:fromLeft]) {
        // Initialization code
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateShareOptions)
                                                     name:UIApplicationDidBecomeActiveNotification object:nil];
        
        CGRect scrollViewBounds = self.bounds;
        scrollViewBounds.size.width = [slidingSidebarView contentBounds].origin.x + [slidingSidebarView contentBounds].size.width;
        sharingContentView = [[UIView alloc] initWithFrame:scrollViewBounds];
        
        buttonView = [[UIView alloc] initWithFrame:[slidingSidebarView contentBounds]];
        [sharingContentView addSubview:buttonView];
        [slidingSidebarView addSubview:sharingContentView];
        
        cloudKitShareItem = [[MMCloudKitShareItem alloc] init];
        
        shareItems = [NSMutableArray array];
        [shareItems addObject:cloudKitShareItem];
        [shareItems addObject:[[MMEmailShareItem alloc] init]];
        [shareItems addObject:[[MMTextShareItem alloc] init]];
        [shareItems addObject:[[MMPhotoAlbumShareItem alloc] init]];
        [shareItems addObject:[[MMSinaWeiboShareItem alloc] init]];
        [shareItems addObject:[[MMTencentWeiboShareItem alloc] init]];
        [shareItems addObject:[[MMTwitterShareItem alloc] init]];
        [shareItems addObject:[[MMFacebookShareItem alloc] init]];
        [shareItems addObject:[[MMPinterestShareItem alloc] init]];
        [shareItems addObject:[[MMImgurShareItem alloc] init]];
        [shareItems addObject:[[MMPrintShareItem alloc] init]];
        [shareItems addObject:[[MMCopyShareItem alloc] init]];
        [shareItems addObject:[[MMOpenInAppShareItem alloc] init]];

        [self updateShareOptions];
        
        
        CGRect typicalBounds = [[shareItems lastObject] button].bounds;
        MMLargeTutorialSidebarButton* button = [[MMLargeTutorialSidebarButton alloc] initWithFrame:typicalBounds andTutorialList:^NSArray *{
            return [[MMTutorialManager sharedInstance] shareTutorialSteps];
        }];
        button.center = CGPointMake(sharingContentView.bounds.size.width/2, sharingContentView.bounds.size.height - 100);
        [sharingContentView addSubview:button];
        
    }
    return self;
}

-(CGFloat) buttonWidth{
    CGFloat buttonWidth = buttonView.bounds.size.width - kWidthOfSidebarButtonBuffer; // four buffers (3 between, and 1 on the right side)
    buttonWidth /= 4; // four buttons wide
    return buttonWidth;
}

-(CGRect) buttonBounds{
    CGFloat buttonWidth = [self buttonWidth];
    CGRect buttonBounds = buttonView.bounds;
    buttonBounds.origin.y = [UIApplication sharedApplication].statusBarFrame.size.height + kWidthOfSidebarButtonBuffer;
    buttonBounds.size.height = buttonWidth + kWidthOfSidebarButtonBuffer; // includes spacing buffer
    buttonBounds.origin.x += 2*kWidthOfSidebarButtonBuffer;
    buttonBounds.size.width -= 2*kWidthOfSidebarButtonBuffer;
    return buttonBounds;
}

-(void) updateShareOptions{
    [NSThread performBlockOnMainThread:^{
        [buttonView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        int buttonIndex = 0;
        CGFloat buttonWidth = [self buttonWidth];
        CGRect buttonBounds = [self buttonBounds];
        for(MMEmailShareItem* item in shareItems){
            if(item.isAtAllPossible){
                item.delegate = self;
                
                MMSidebarButton* button = item.button;
                int column = (buttonIndex%4);
                int row = floor(buttonIndex / 4.0);
                button.frame = CGRectMake(buttonBounds.origin.x + column*(buttonWidth),
                                          buttonBounds.origin.y + row*(buttonWidth),
                                          buttonWidth, buttonWidth);
                
                [buttonView insertSubview:button atIndex:buttonIndex];
                
                buttonIndex += 1;
            }
        }
        
        UIView* lastButton = [buttonView.subviews lastObject];
        CGRect fr = buttonView.frame;
        fr.size.height = lastButton.frame.origin.y + lastButton.frame.size.height + kWidthOfSidebarButtonBuffer;
        buttonView.frame = fr;
    }];
}

#pragma mark - Sharing button tapped

-(void) show:(BOOL)animated{
    for (NSObject<MMShareItem>*shareItem in shareItems) {
        if([shareItem respondsToSelector:@selector(willShow)]){
            [shareItem willShow];
        }
    }
    [activeOptionsView reset];
    [activeOptionsView show];
    [super show:animated];
}

-(void) hide:(BOOL)animated onComplete:(void(^)(BOOL finished))onComplete{
    [super hide:animated onComplete:^(BOOL finished){
        [activeOptionsView hide];
        if(activeOptionsView.shouldCloseWhenSidebarHides){
            [self closeActiveSharingOptionsForButton:nil];
            while([sharingContentView.subviews count] > 1){
                // remove any options views
                [[sharingContentView.subviews objectAtIndex:1] removeFromSuperview];
            }
        }
        // notify any buttons that they're now hidden.
        for (NSObject<MMShareItem>*shareItem in shareItems) {
            if([shareItem respondsToSelector:@selector(didHide)]){
                [shareItem didHide];
            }
        }
        if(onComplete){
            onComplete(finished);
        }
    }];
}


-(NSObject<MMShareItem>*) closeActiveSharingOptionsForButton:(UIButton*)button{
    if(activeOptionsView){
        [activeOptionsView removeFromSuperview];
        [activeOptionsView reset];
    }
    NSObject<MMShareItem>*shareItemForButton = nil;
    for (NSObject<MMShareItem>*shareItem in shareItems) {
        if(shareItem.button == button){
            shareItemForButton = shareItem;
        }
        if([shareItem respondsToSelector:@selector(setIsShowingOptionsView:)]){
            shareItem.isShowingOptionsView = NO;
        }
    }
    return shareItemForButton;
}

#pragma mark - Rotation

-(CGFloat) sidebarButtonRotation{
    if([MMRotationManager sharedInstance].lastBestOrientation == UIInterfaceOrientationPortrait){
        return 0;
    }else if([MMRotationManager sharedInstance].lastBestOrientation == UIInterfaceOrientationLandscapeLeft){
        return -M_PI_2;
    }else if([MMRotationManager sharedInstance].lastBestOrientation == UIInterfaceOrientationLandscapeRight){
        return M_PI_2;
    }else{
        return M_PI;
    }
}

-(void) updateInterfaceTo:(UIInterfaceOrientation)orientation{
    [activeOptionsView updateInterfaceTo:orientation];
    [UIView animateWithDuration:.3 animations:^{
        CGAffineTransform rotationTransform = CGAffineTransformMakeRotation([self sidebarButtonRotation]);
        for(MMBounceButton* button in buttonView.subviews){
            button.rotation = [self sidebarButtonRotation];
            button.transform = rotationTransform;
        }
    }];
}

#pragma mark - MMShareItemDelegate

-(UIImage*) imageToShare{
    return shareDelegate.imageToShare;
}

-(NSDictionary*) cloudKitSenderInfo{
    return shareDelegate.cloudKitSenderInfo;
}


-(void) mayShare:(NSObject<MMShareItem> *)shareItem{
    // close out all of our sharing options views,
    // if any
    [self closeActiveSharingOptionsForButton:nil];
    // now check if our new item has a sharing
    // options panel or not
    // if a popover controller is dismissed, it
    // adds the dismissal to the main queue async
    // so we need to add our next steps /after that/
    // so we need to dispatch async too
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            if([shareItem respondsToSelector:@selector(optionsView)]){
                activeOptionsView = [shareItem optionsView];
                [activeOptionsView reset];
                CGRect frForOptions = buttonView.frame;
                frForOptions.origin.y = buttonView.bounds.size.height;
                frForOptions.size.height = sharingContentView.bounds.size.height - buttonView.frame.origin.y - buttonView.frame.size.height;
                activeOptionsView.frame = frForOptions;
                if([shareItem respondsToSelector:@selector(setIsShowingOptionsView:)]){
                    shareItem.isShowingOptionsView = YES;
                }
                [sharingContentView addSubview:activeOptionsView];
            }else{
                activeOptionsView = nil;
            }
            
            [shareDelegate mayShare:shareItem];
        }
    });
}

-(void) didShare:(NSObject<MMShareItem> *)shareItem{
    [shareDelegate didShare:shareItem];
}

-(void) didShare:(NSObject<MMShareItem> *)shareItem toUser:(CKRecordID*)userId fromButton:(MMAvatarButton*)button{
    [shareDelegate didShare:shareItem toUser:userId fromButton:button];
}

#pragma mark - Cloud Kit State

-(void) cloudKitDidChangeState:(MMCloudKitBaseState *)currentState{
    [cloudKitShareItem cloudKitDidChangeState:currentState];
}


#pragma mark - Dealloc

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
