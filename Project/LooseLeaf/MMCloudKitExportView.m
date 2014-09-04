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
#import "Constants.h"

@implementation MMCloudKitExportView{
    NSMutableSet* disappearingButtons;
    NSMutableArray* activeExports;
    NSMutableArray* activeImports;
    
    NSTimer* bounceTimer;
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
    @synchronized(activeExports){
        [activeExports addObject:exportCoordinator];
    }
    [self animateAvatarButtonToTopOfPage:avatarButton onComplete:^{
        [exportCoordinator begin];
    }];
}

-(void) exportComplete:(MMCloudKitExportCoordinator*)exportCoord{
    [disappearingButtons removeObject:exportCoord.avatarButton];
    @synchronized(activeExports){
        [activeExports removeObject:exportCoord];
    }
    [self animateAndAlignAllButtons];
}

-(void) exportIsCompleting:(MMCloudKitExportCoordinator*)exportCoord{
    [disappearingButtons addObject:exportCoord.avatarButton];
    [self animateAndAlignAllButtons];
}

#pragma mark - Export Notifications

-(void) didFailToExportPage:(MMPaperView*)page{
    @synchronized(activeExports){
        for(MMCloudKitExportCoordinator* export in activeExports){
            if(export.page == page){
                [export zipGenerationFailed];
            }
        }
    }
}

-(void) didExportPage:(MMPaperView*)page toZipLocation:(NSString*)fileLocationOnDisk{
    NSLog(@"zip file: %d %@", [[NSFileManager defaultManager] fileExistsAtPath:fileLocationOnDisk], fileLocationOnDisk);
    
    @synchronized(activeExports){
        for(MMCloudKitExportCoordinator* export in activeExports){
            if(export.page == page){
                [export zipGenerationIsCompleteAt:fileLocationOnDisk];
            }
        }
    }
}

-(void) isExportingPage:(MMPaperView*)page withPercentage:(CGFloat)percentComplete toZipLocation:(NSString*)fileLocationOnDisk{
    @synchronized(activeExports){
        for(MMCloudKitExportCoordinator* export in activeExports){
            if(export.page == page){
                [export zipGenerationIsPercentComplete:percentComplete];
            }
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
    [UIView animateWithDuration:.3 animations:^{
        int i=0;
        @synchronized(activeExports){
            for(MMCloudKitExportCoordinator* export in [activeExports reverseObjectEnumerator]){
                if(![disappearingButtons containsObject:export.avatarButton] &&
                   ![animationHelperView containsSubview:export.avatarButton]){
                    CGRect fr = export.avatarButton.frame;
                    fr.origin.x = 100 + export.avatarButton.frame.size.width/2*(i+[animationHelperView.subviews count]);
                    export.avatarButton.frame = fr;
                    i++;
                }
            }
        }
        i = 0;
        @synchronized(activeImports){
            for(MMCloudKitExportCoordinator* import in [activeImports reverseObjectEnumerator]){
                if(![disappearingButtons containsObject:import.avatarButton] &&
                   ![animationHelperView containsSubview:import.avatarButton]){
                    CGRect fr = import.avatarButton.frame;
                    fr.origin.x = self.bounds.size.width - 100 - import.avatarButton.frame.size.width/3*i;
                    import.avatarButton.frame = fr;
                    i++;
                }
            }
        }
    }];
}

-(void) animateImportAvatarButtonToTopOfPage:(MMAvatarButton*)avatarButton onComplete:(void (^)())completion{
    CGRect fr = CGRectMake(self.bounds.size.width - 100, 0, avatarButton.bounds.size.width, avatarButton.bounds.size.height);
    avatarButton.frame = fr;
    [self addSubview:avatarButton];

    avatarButton.shouldDrawDarkBackground = YES;
    [avatarButton setNeedsDisplay];
    
    avatarButton.alpha = 0;
    CGPoint offscreen = CGPointMake(avatarButton.center.x, avatarButton.center.y - avatarButton.bounds.size.height / 2);
    [avatarButton animateOnScreenFrom:offscreen withCompletion:^(BOOL finished) {
        [self animateAndAlignAllButtons];
        if(completion) completion();
    }];
    [self animateAndAlignAllButtons];
}


#pragma mark - MMCloudKitManagerDelegate

-(void) cloudKitDidChangeState:(MMCloudKitBaseState*)currentState{
    // noop
}

-(void) willFetchMessage:(SPRMessage*)message{
    // noop
}

-(void) didFetchMessage:(SPRMessage *)message{
    MMCloudKitImportCoordinator* coordinator = [[MMCloudKitImportCoordinator alloc] initWithImport:message forExportView:self];
    @synchronized(activeImports){
        [activeImports addObject:coordinator];
    }
    [coordinator begin];
}

-(void) didFailToFetchMessage:(SPRMessage *)message{
    NSLog(@"failed fetching message");
}

#pragma mark - MMCloudKitManagerDelegate

-(void) importCoordinatorIsReady:(MMCloudKitImportCoordinator*)coordinator{
//    NSLog(@"beginning import animation");
    // other coordinators in the list may still be waiting for
    // their zip file to process, so make sure that coordinators
    // are sorted by their readiness
    @synchronized(activeImports){
        [activeImports removeObject:coordinator];
        [activeImports addObject:coordinator];
    }
    [self animateImportAvatarButtonToTopOfPage:coordinator.avatarButton onComplete:^{
//        NSLog(@"done processing zip, ready to import");
    }];
    [self animateAndAlignAllButtons];
    
    
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"hasEverImportedAPage"]){
        if(!bounceTimer){
            bounceTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(bounceMostRecentImport) userInfo:nil repeats:YES];
        }
    }
}

-(void) bounceMostRecentImport{
    @synchronized(activeImports){
        for (MMCloudKitImportCoordinator* coordinator in [activeImports reverseObjectEnumerator]) {
            if(coordinator.isReady){
                [coordinator.avatarButton animateOnScreenFrom:coordinator.avatarButton.center withCompletion:nil];
                break;
            }
        }
    }
}

-(void) importWasTapped:(MMCloudKitImportCoordinator*)coordinator{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"hasEverImportedAPage"];
    [bounceTimer invalidate];
    bounceTimer = nil;
    
    NSLog(@"time to show this page %@", coordinator);
    if(coordinator.uuidOfIncomingPage){
        MMExportablePaperView* page = [[MMExportablePaperView alloc] initWithFrame:stackView.bounds andUUID:coordinator.uuidOfIncomingPage];
        if(page){
            [stackView importAndShowPage:page];
        }else{
            NSLog(@"couldn't build page for %@", coordinator.uuidOfIncomingPage);
        }
    }else{
        NSLog(@"couldn't create page for %@", coordinator);
    }
    
    @synchronized(activeImports){
        [activeImports removeObject:coordinator];
    }
    [coordinator.avatarButton animateOffScreenWithCompletion:nil];
    [self animateAndAlignAllButtons];
}

#pragma mark - Touch Control

- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    MMCloudKitImportCoordinator* import = nil;
    @synchronized(activeImports){
        for (MMCloudKitImportCoordinator* coordinator in [activeImports reverseObjectEnumerator]) {
            if(coordinator.isReady){
                import = coordinator;
                break;
            }
        }
    }

    if([import.avatarButton pointInside:[self convertPoint:point toView:import.avatarButton] withEvent:event]){
        return YES;
    }
    return [super pointInside:point withEvent:event];
}

-(UIView*) hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    MMCloudKitImportCoordinator* import = nil;
    @synchronized(activeImports){
        for (MMCloudKitImportCoordinator* coordinator in [activeImports reverseObjectEnumerator]) {
            if(coordinator.isReady){
                import = coordinator;
                break;
            }
        }
    }

    if([import.avatarButton pointInside:[self convertPoint:point toView:import.avatarButton] withEvent:event]){
        return import.avatarButton;
    }
    return [super hitTest:point withEvent:event];
}

@end
