//
//  MMCloudKitExportCoordinator.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/28/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCloudKitExportCoordinator.h"
#import "NSThread+BlockAdditions.h"
#import "MMCloudKitExportView.h"
#import "MMExportablePaperView.h"

#define kPercentCompleteAtStart .15
#define kPercentCompleteOfZip .55

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
                // noop
            }];
        } afterDelay:.5];
    }];
}

-(void) zipGenerationIsPercentComplete:(CGFloat)percentComplete{
    avatarButton.targetProgress = kPercentCompleteAtStart + kPercentCompleteOfZip*percentComplete;
}

-(void) zipGenerationIsCompleteAt:(NSString*)pathToZipFile{
    [self complete];
}

-(void) complete{
    avatarButton.targetProgress = 1.0;
}

@end
