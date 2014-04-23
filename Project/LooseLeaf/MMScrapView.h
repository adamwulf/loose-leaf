//
//  MMScrap.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/23/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JotUI/JotUI.h>
#import "MMScrapViewStateDelegate.h"
#import "MMScrapViewState.h"

@interface MMScrapView : UIView<MMScrapViewStateDelegate>

@property (readonly) CGAffineTransform clippingPathTransform;
@property (readonly) UIBezierPath* clippingPath;
@property (readonly) UIBezierPath* bezierPath;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) CGFloat rotation;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, readonly) CGSize originalSize;
@property (nonatomic, readonly) NSString* uuid;
@property (nonatomic, readonly) MMScrapViewState* state;

-(id) initWithScrapViewState:(MMScrapViewState*)scrapState;
- (id)initWithBezierPath:(UIBezierPath*)path;

-(void) didUpdateAccelerometerWithRawReading:(CGFloat)currentRawReading;

-(BOOL) containsTouch:(UITouch*)touch;

-(void) setScale:(CGFloat)scale andRotation:(CGFloat)rotation;

-(void) setShouldShowShadow:(BOOL)shouldShowShadow;

-(void) stampContentsFrom:(JotView*)otherDrawableView;

/**
 * will return the array of touches that this scrap
 * contains, but only if more than one touch
 * will match
 */
-(NSSet*) matchingPairTouchesFrom:(NSSet*) touches;
-(NSSet*) allMatchingTouchesFrom:(NSSet*) touches;

-(void) addElements:(NSArray*)elements;

-(void) saveToDisk:(void(^)())doneSavingBlock;

-(void) loadScrapStateAsynchronously:(BOOL)async;

-(void) unloadState;

-(CGAffineTransform) pageToScrapTransformWithPageOriginalUnscaledBounds:(CGRect)originalUnscaledBounds;


-(void) drawTexture:(JotGLTexture*)texture atP1:(CGPoint)p1 andP2:(CGPoint)p2 andP3:(CGPoint)p3 andP4:(CGPoint)p4;


-(UIImage*) backingImage;
-(void) setBackingImage:(UIImage*)img;
-(void) setBackgroundRotation:(CGFloat)rotation;
-(CGFloat) backgroundRotation;
-(void) setBackgroundScale:(CGFloat)_backgroundScale;
-(CGFloat) backgroundScale;
-(void) setBackgroundOffset:(CGPoint)bgOffset;
-(CGPoint) backgroundOffset;

@end
