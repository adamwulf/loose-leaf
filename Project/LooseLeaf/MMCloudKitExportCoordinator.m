//
//  MMCloudKitExportCoordinator.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/28/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCloudKitExportCoordinator.h"
#import "MMCloudKitManager.h"
#import "MMCloudKitLoggedInState.h"
#import <SimpleCloudKitManager/SPRSimpleCloudKitManager.h>
#import "MMCloudKitExportView.h"
#import "MMExportablePaperView.h"
#import "NSThread+BlockAdditions.h"

#define kPercentCompleteAtStart  .15
#define kPercentCompleteOfZip    .20
#define kPercentCompleteOfUpload .55

@implementation MMCloudKitExportCoordinator{
    MMExportablePaperView* page;
    CKRecordID* userId;
    MMCloudKitExportView* exportView;
}

@synthesize avatarButton;
@synthesize page;

-(id) initWithPage:(MMExportablePaperView*)_page andRecipient:(CKRecordID*)_userId withButton:(MMAvatarButton*)_avatarButton forExportView:(MMCloudKitExportView*)_exportView{
    if(self = [super init]){
        page = _page;
        userId = _userId;
        avatarButton = _avatarButton;
        exportView = _exportView;
    }
    return self;
}

-(void) begin{
    [page exportAsynchronouslyToZipFile];
    [avatarButton animateToPercent:kPercentCompleteAtStart success:YES completion:^(BOOL success) {
        if(success){
            NSLog(@"CloudKit success");
        }else{
            NSLog(@"CloudKit failure");
        }
        [[NSThread mainThread] performBlock:^{
            [exportView exportIsCompleting:self];
            [avatarButton animateOffScreenWithCompletion:^(BOOL finished) {
                [exportView exportComplete:self];
            }];
        } afterDelay:.5];
    }];
}

-(void) zipGenerationIsPercentComplete:(CGFloat)percentComplete{
    avatarButton.targetProgress = kPercentCompleteAtStart + kPercentCompleteOfZip*percentComplete;
}

-(void) zipGenerationFailed{
    avatarButton.targetSuccess = NO;
    [self complete];
}

-(void) zipGenerationIsCompleteAt:(NSString*)pathToZipFile{
    if([[MMCloudKitManager sharedManager] isLoggedInAndReadyForAnything]){
        avatarButton.targetProgress = kPercentCompleteAtStart + kPercentCompleteOfZip;
        [[SPRSimpleCloudKitManager sharedManager] sendMessage:@"foobar!"
                                                 withImageURL:[[NSURL alloc] initFileURLWithPath:pathToZipFile]
                                               toUserRecordID:userId
                                          withProgressHandler:^(CGFloat progress) {
                                              avatarButton.targetProgress = kPercentCompleteAtStart + kPercentCompleteOfZip + kPercentCompleteOfUpload*progress;
                                          }
                                        withCompletionHandler:^(NSError *error) {
                                            if(error){
                                                avatarButton.targetSuccess = NO;
                                            }else{
                                                avatarButton.targetSuccess = YES;
                                            }
                                            [self complete];
                                        }];
    }else{
        // failed, cloudkit isn't logged in
        avatarButton.targetSuccess = NO;
        [self complete];
    }
}

-(void) complete{
    avatarButton.targetProgress = 1.0;
}

@end
