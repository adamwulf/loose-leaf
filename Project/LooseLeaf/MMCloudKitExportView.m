//
//  MMCloudKitExportAnimationView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/27/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCloudKitExportView.h"
#import "MMUntouchableView.h"
#import "NSThread+BlockAdditions.h"
#import "MMCloudKitExportCoordinator.h"
#import "MMCloudKitImportCoordinator.h"
#import "MMScrapPaperStackView.h"
#import "CKDiscoveredUserInfo+Initials.h"
#import "Constants.h"

@implementation MMCloudKitExportView{
    NSMutableSet* disappearingButtons;
    NSMutableArray* activeExports;
    NSMutableArray* activeImports;
}

@synthesize stackView;
@synthesize animationHelperView;

-(id) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        disappearingButtons = [NSMutableSet set];
        activeExports = [NSMutableArray array];
        activeImports = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Sharing

-(void) didShareTopPageToUser:(CKRecordID*)userId fromButton:(MMAvatarButton*)avatarButton{
    MMCloudKitExportCoordinator* exportCoordinator = [[MMCloudKitExportCoordinator alloc] initWithPage:[stackView.visibleStackHolder peekSubview]
                                                                                          andRecipient:userId
                                                                                            withButton:avatarButton
                                                                                         forExportView:self];
    [activeExports addObject:exportCoordinator];
    [self animateAvatarButtonToTopOfPage:avatarButton onComplete:^{
        [exportCoordinator begin];
    }];
}

-(void) exportComplete:(MMCloudKitExportCoordinator*)exportCoord{
    [disappearingButtons removeObject:exportCoord.avatarButton];
    [activeExports removeObject:exportCoord];
    [self animateAndAlignAllButtons];
}

-(void) exportIsCompleting:(MMCloudKitExportCoordinator*)exportCoord{
    [disappearingButtons addObject:exportCoord.avatarButton];
    [self animateAndAlignAllButtons];
}

#pragma mark - Export Notifications

-(void) didFailToExportPage:(MMPaperView*)page{
    for(MMCloudKitExportCoordinator* export in activeExports){
        if(export.page == page){
            [export zipGenerationFailed];
        }
    }
}

-(void) didExportPage:(MMPaperView*)page toZipLocation:(NSString*)fileLocationOnDisk{
    NSLog(@"zip file: %d %@", [[NSFileManager defaultManager] fileExistsAtPath:fileLocationOnDisk], fileLocationOnDisk);
    
    for(MMCloudKitExportCoordinator* export in activeExports){
        if(export.page == page){
            [export zipGenerationIsCompleteAt:fileLocationOnDisk];
        }
    }
}

-(void) isExportingPage:(MMPaperView*)page withPercentage:(CGFloat)percentComplete toZipLocation:(NSString*)fileLocationOnDisk{
    for(MMCloudKitExportCoordinator* export in activeExports){
        if(export.page == page){
            [export zipGenerationIsPercentComplete:percentComplete];
        }
    }
}

#pragma mark - Animations

-(void) animateAvatarButtonToTopOfPage:(MMAvatarButton*)avatarButton onComplete:(void (^)())completion{
    CGRect fr = [avatarButton convertRect:avatarButton.bounds toView:self];
    avatarButton.frame = fr;
    [animationHelperView addSubview:avatarButton];
    
    avatarButton.shouldDrawDarkBackground = YES;
    [avatarButton setNeedsDisplay];
    
    [avatarButton animateBounceToTopOfScreenAtX:100 withDuration:0.8 completion:^(BOOL finished) {
        [self addSubview:avatarButton];
        [self animateAndAlignAllButtons];
        if(completion) completion();
    }];
    [self animateAndAlignAllButtons];
}

-(void) animateAndAlignAllButtons{
    [UIView animateWithDuration:.5 animations:^{
        int i=0;
        for(MMCloudKitExportCoordinator* export in [activeExports reverseObjectEnumerator]){
            if(![disappearingButtons containsObject:export.avatarButton] &&
               ![animationHelperView containsSubview:export.avatarButton]){
                CGRect fr = export.avatarButton.frame;
                fr.origin.x = 100 + export.avatarButton.frame.size.width/2*(i+[animationHelperView.subviews count]);
                export.avatarButton.frame = fr;
                i++;
            }
        }
        for(MMCloudKitExportCoordinator* import in activeImports){
            if(![disappearingButtons containsObject:import.avatarButton] &&
               ![animationHelperView containsSubview:import.avatarButton]){
                CGRect fr = import.avatarButton.frame;
                fr.origin.x = 100 + import.avatarButton.frame.size.width/2*(i+[animationHelperView.subviews count]);
                import.avatarButton.frame = fr;
                i++;
            }
        }
    }];
}


#pragma mark - MMCloudKitManagerDelegate

-(void) cloudKitDidChangeState:(MMCloudKitBaseState*)currentState{
    // noop
}

-(void) didRecieveMessageFrom:(CKDiscoveredUserInfo*)sender forZip:(NSString*)pathToZip{
    NSLog(@"got message");
    MMAvatarButton* senderButton = [[MMAvatarButton alloc] initWithFrame:CGRectMake(0, 0, 80, 80) forLetter:sender.initials];
    MMCloudKitImportCoordinator* coordinator = [[MMCloudKitImportCoordinator alloc] initWithSender:sender andButton:senderButton andZipFile:pathToZip];
    [activeImports addObject:coordinator];
    [coordinator begin];
}

-(void) didFailToFetchMessage:(CKRecordID*)messageID withProperties:(NSDictionary*)properties{
    NSLog(@"got message failed");
}

@end
