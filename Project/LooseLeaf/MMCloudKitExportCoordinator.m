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
#import "NSFileManager+DirectoryOptimizations.h"
#import "NSThread+BlockAdditions.h"
#import "Mixpanel.h"

#define kPercentCompleteAtStart  .15
#define kPercentCompleteOfZip    .20
#define kPercentCompleteOfUpload .55

#define kZipArchiveErrorDomain @"com.milestonemade.looseleaf.ZipArchive"

@implementation MMCloudKitExportCoordinator{
    NSError* error;
    MMExportablePaperView* page;
    CKRecordID* userId;
    MMCloudKitExportView* exportView;
    
    BOOL zipIsComplete;
    NSDictionary* zipAttributes;
}

@synthesize avatarButton;
@synthesize page;

-(id) initWithPage:(MMExportablePaperView*)_page andRecipient:(CKRecordID*)_userId withButton:(MMAvatarButton*)_avatarButton forExportView:(MMCloudKitExportView*)_exportView{
    if(self = [super init]){
        page = _page;
        userId = _userId;
        avatarButton = _avatarButton;
        exportView = _exportView;
        zipIsComplete = NO;
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
        } afterDelay:success ? .5 : 3.5];
    }];
}

-(void) zipGenerationIsPercentComplete:(CGFloat)percentComplete{
    avatarButton.targetProgress = kPercentCompleteAtStart + kPercentCompleteOfZip*percentComplete;
}

-(void) zipGenerationFailed{
    if(!zipIsComplete){
        zipIsComplete = YES;
        error = [NSError errorWithDomain:kZipArchiveErrorDomain code:500 userInfo:nil];
        avatarButton.targetSuccess = NO;
        [self complete];
    }
}

-(void) zipGenerationIsCompleteAt:(NSString*)pathToZipFile{
    if(!zipIsComplete){
        zipIsComplete = YES;
        
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        CGFloat scale = [UIScreen mainScreen].scale;
        CGFloat assetSize = [[NSFileManager defaultManager] sizeForItemAtPath:pathToZipFile];
        NSString* readableSize = [[NSFileManager defaultManager] humanReadableSizeForItemAtPath:pathToZipFile];
        
        if([[MMCloudKitManager sharedManager] isLoggedInAndReadyForAnything]){
            avatarButton.targetProgress = kPercentCompleteAtStart + kPercentCompleteOfZip;
            zipAttributes = @{@"width":@(screenSize.width),
                              @"height":@(screenSize.height),
                              @"scale":@(scale),
                              @"assetSize": @(assetSize),
                              @"readableSize":readableSize};
            [[SPRSimpleCloudKitManager sharedManager] sendFile:[[NSURL alloc] initFileURLWithPath:pathToZipFile]
                                                withAttributes:zipAttributes
                                                   toUserRecordID:userId
                                              withProgressHandler:^(CGFloat progress) {
                                                  avatarButton.targetProgress = kPercentCompleteAtStart + kPercentCompleteOfZip + kPercentCompleteOfUpload*progress;
                                              }
                                            withCompletionHandler:^(NSError *_err) {
                                                if(_err){
                                                    error = _err;
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
}

-(void) complete{
    NSMutableDictionary* eventProperties = [NSMutableDictionary dictionary];
    if(zipAttributes){
        for(NSString* key in [zipAttributes allKeys]){
            [eventProperties setObject:[zipAttributes objectForKey:key] forKey:[NSString stringWithFormat:@"ExportAttr: %@", key]];
        }
    }
    
    avatarButton.targetProgress = 1.0;
    if(!error){
        [eventProperties addEntriesFromDictionary:@{kMPEventExportPropDestination : @"CloudKit",
                                                    kMPEventExportPropResult : @"Success"}];
        [[[Mixpanel sharedInstance] people] increment:kMPNumberOfCloudKitExports by:@(1)];
        [[[Mixpanel sharedInstance] people] increment:kMPNumberOfExports by:@(1)];
        [[Mixpanel sharedInstance] track:kMPEventExport properties:eventProperties];
    }else{
        if([error.domain isEqualToString:SPRSimpleCloudKitMessengerErrorDomain]){
            
            NSString* reason = @"Unknown";
            if(error.code == SPRSimpleCloudMessengerErrorUnexpected){
                reason = @"Unexpected";
            }else if(error.code == SPRSimpleCloudMessengerErroriCloudAccount){
                reason = @"iCloud Account";
            }else if(error.code == SPRSimpleCloudMessengerErrorMissingDiscoveryPermissions){
                reason = @"Discovery Permissions";
            }else if(error.code == SPRSimpleCloudMessengerErrorNetwork){
                reason = @"Network Error";
            }else if(error.code == SPRSimpleCloudMessengerErrorServiceUnavailable){
                reason = @"Service Unavailable";
            }else if(error.code == SPRSimpleCloudMessengerErrorCancelled){
                reason = @"Cancelled";
            }else if(error.code == SPRSimpleCloudMessengerErroriCloudAccountChanged){
                reason = @"iCloud Account Changed";
            }
            [eventProperties addEntriesFromDictionary:@{kMPEventExportPropDestination : @"CloudKit",
                                                        kMPEventExportPropResult : reason}];
            
            [[Mixpanel sharedInstance] track:kMPEventExport properties:eventProperties];
        }else if([error.domain isEqualToString:kZipArchiveErrorDomain]){
            [eventProperties addEntriesFromDictionary:@{kMPEventExportPropDestination : @"CloudKit",
                                                        kMPEventExportPropResult : @"Zip Failed"}];
            [[Mixpanel sharedInstance] track:kMPEventExport properties:eventProperties];
        }else{
            [eventProperties addEntriesFromDictionary:@{kMPEventExportPropDestination : @"CloudKit",
                                                        kMPEventExportPropResult : [NSString stringWithFormat:@"%@:%d", error.domain, (int)error.code]}];
            [[Mixpanel sharedInstance] track:kMPEventExport properties:eventProperties];
        }
    }
}

@end
