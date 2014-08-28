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
#import "MMScrapPaperStackView.h"
#import "Constants.h"

@implementation MMCloudKitExportView{
    NSMutableSet* disappearingButtons;
    NSMutableArray* activeExports;
}

@synthesize stackView;
@synthesize animationHelperView;

-(id) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        disappearingButtons = [NSMutableSet set];
        activeExports = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Sharing

-(void) didShareTopPageToUser:(CKRecordID*)userId fromButton:(MMAvatarButton*)avatarButton{
    [activeExports addObject:[[MMCloudKitExportCoordinator alloc] initWithPage:[stackView.visibleStackHolder peekSubview] andRecipient:userId withButton:avatarButton forExportView:self]];
    [self animateAvatarButtonToTopOfPage:avatarButton];
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

-(void) didExportPage:(MMPaperView*)page toZipLocation:(NSString*)fileLocationOnDisk{
    NSLog(@"did export page %@ to %@", page.uuid, fileLocationOnDisk);
    for(MMCloudKitExportCoordinator* export in activeExports){
        if(export.page == page){
            [export complete];
            NSLog(@"found export: %p", export);
        }
    }
}

#pragma mark - Animations

-(void) animateAvatarButtonToTopOfPage:(MMAvatarButton*)avatarButton{
    CGRect fr = [avatarButton convertRect:avatarButton.bounds toView:self];
    avatarButton.frame = fr;
    [animationHelperView addSubview:avatarButton];
    
    avatarButton.shouldDrawDarkBackground = YES;
    [avatarButton setNeedsDisplay];
    
    [avatarButton animateBounceToTopOfScreenAtX:100 withDuration:0.8 completion:^(BOOL finished) {
        [self addSubview:avatarButton];
        [self animateAndAlignAllButtons];
    }];
    [self animateAndAlignAllButtons];
}

-(void) animateAndAlignAllButtons{
    [UIView animateWithDuration:.5 animations:^{
        int i=0;
        for(MMAvatarButton* button in [self.subviews reverseObjectEnumerator]){
            if([button isKindOfClass:[MMAvatarButton class]] &&
               ![disappearingButtons containsObject:button]){
                
                CGRect fr = button.frame;
                fr.origin.x = 100 + button.frame.size.width/2*(i+[animationHelperView.subviews count]);
                button.frame = fr;
                i++;
            }
        }
    }];
}

@end
