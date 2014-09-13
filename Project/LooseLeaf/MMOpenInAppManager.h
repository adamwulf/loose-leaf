//
//  MMShareManager.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/10/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMOpenInAppManagerDelegate.h"

@interface MMOpenInAppManager : NSObject<UIDocumentInteractionControllerDelegate>

@property (readonly) NSArray* allFoundCollectionViews;
@property (weak) NSObject<MMOpenInAppManagerDelegate>* delegate;

+ (BOOL) shouldListenToRegisterViews;
+(MMOpenInAppManager*) sharedInstance;
+(UIView*)shareTargetView;
+(void) setShareTargetView:(UIView*)shareTargetView;

// called when the share manager should begin looking
// for applications and AirDrop share targets
-(void) beginSharingWithURL:(NSURL*)fileLocation;

// called when we no longer need share targets
-(void) endSharing;

-(NSUInteger) numberOfShareTargets;

-(UIView*) viewForIndexPath:(NSIndexPath*)indexPath forceGet:(BOOL)force;

// UIView registration used by UIView+SuperWatch
-(void) addCollectionView:(UICollectionView*)view;

-(void) registerDismissView:(UIView*)dismissView;

@end
