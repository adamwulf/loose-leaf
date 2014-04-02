//
//  MMScrapViewState.h
//  LooseLeaf
//
//  Created by Adam Wulf on 10/1/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JotUI/JotUI.h>
#import "MMScrapViewStateDelegate.h"

@interface MMScrapViewState : NSObject{
    __weak NSObject<MMScrapViewStateDelegate>* delegate;
}

@property (weak) NSObject<MMScrapViewStateDelegate>* delegate;
@property (readonly) UIBezierPath* bezierPath;
@property (readonly) CGSize originalSize;
@property (readonly) UIView* contentView;
@property (readonly) CGRect drawableBounds;
@property (readonly) NSString* uuid;
@property (readonly) JotView* drawableView;

-(id) initWithUUID:(NSString*)uuid;

-(id) initWithUUID:(NSString*)uuid andBezierPath:(UIBezierPath*)bezierPath;

-(void) saveToDisk;

-(void) loadStateAsynchronously:(BOOL)async;

-(void) unloadState;

-(BOOL) isStateLoaded;

-(void) addElements:(NSArray*)elements;

-(JotGLTexture*) generateTexture;
-(void) importTexture:(JotGLTexture*)texture atP1:(CGPoint)p1 andP2:(CGPoint)p2 andP3:(CGPoint)p3 andP4:(CGPoint)p4;

-(UIImage*) backingImage;
-(void) setBackingImage:(UIImage*)img;

@end
