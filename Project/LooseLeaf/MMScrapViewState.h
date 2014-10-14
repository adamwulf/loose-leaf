//
//  MMScrapViewState.h
//  LooseLeaf
//
//  Created by Adam Wulf on 10/1/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JotUI/JotUI.h>
#import "MMScrapBackgroundView.h"
#import "MMScrapViewStateDelegate.h"
#import "MMScrapCollectionState.h"

@interface MMScrapViewState : NSObject<JotViewStateProxyDelegate>{
    // unloadable state
    // this state can be loaded and unloaded
    // to conserve memeory as needed
    JotViewStateProxy* drawableViewState;
    // delegate
    __weak NSObject<MMScrapViewStateDelegate>* delegate;
    // our owning paper
    __weak MMScrapCollectionState* scrapsOnPaperState;
}

@property (weak) NSObject<MMScrapViewStateDelegate>* delegate;
@property (readonly) UIBezierPath* bezierPath;
@property (readonly) CGSize originalSize;
@property (readonly) UIView* contentView;
@property (readonly) CGRect drawableBounds;
@property (readonly) NSString* uuid;
@property (readonly) JotView* drawableView;
@property (readonly) NSString* pathForScrapAssets;
@property (nonatomic, weak) MMScrapCollectionState* scrapsOnPaperState;
@property (nonatomic, readonly) int fullByteSize;
@property (readonly) NSUInteger lastSavedUndoHash;

-(id) initWithUUID:(NSString*)uuid andPaperState:(MMScrapCollectionState*)scrapsOnPaperState;

-(id) initWithUUID:(NSString*)uuid andBezierPath:(UIBezierPath*)bezierPath andPaperState:(MMScrapCollectionState*)scrapsOnPaperState;

-(void) saveScrapStateToDisk:(void(^)(BOOL hadEditsToSave))doneSavingBlock;

-(void) loadScrapStateAsynchronously:(BOOL)async;

-(void) unloadState;

-(BOOL) isScrapStateLoaded;
-(BOOL) isScrapStateLoading;
-(BOOL) hasEditsToSave;

-(UIImage*) activeThumbnailImage;

-(void) addElements:(NSArray*)elements;
-(void) addUndoLevelAndFinishStroke;

-(JotGLTexture*) generateTexture;
-(void) importTexture:(JotGLTexture*)texture atP1:(CGPoint)p1 andP2:(CGPoint)p2 andP3:(CGPoint)p3 andP4:(CGPoint)p4;


-(MMScrapBackgroundView*) backgroundView;
-(void) setBackgroundView:(MMScrapBackgroundView*)backgroundView;
-(CGPoint) currentCenterOfScrapBackground;
-(void) reloadBackgroundView;

-(UIView*) contentView;

@end
