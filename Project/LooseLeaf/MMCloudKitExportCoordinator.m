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

@implementation MMCloudKitExportCoordinator{
    MMUndoablePaperView* page;
    CKRecordID* userId;
    MMCloudKitExportView* exportView;
}

@synthesize avatarButton;

-(id) initWithPage:(MMUndoablePaperView*)_page andRecipient:(CKRecordID*)_userId withButton:(MMAvatarButton*)_avatarButton forExportView:(MMCloudKitExportView*)_exportView{
    if(self = [super init]){
        page = _page;
        userId = _userId;
        avatarButton = _avatarButton;
        exportView = _exportView;
    }
    [self begin];
    return self;
}

-(void) begin{
    [avatarButton animateToPercent:1.0 success:YES completion:^(BOOL success) {
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
        } afterDelay:10.0 + rand()%10];
    }];
}

@end
