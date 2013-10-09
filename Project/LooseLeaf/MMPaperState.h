//
//  MMPaperState.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/24/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JotUI/JotUI.h>
#import "MMPaperStateDelegate.h"

@interface MMPaperState : NSObject{
    NSObject<MMPaperStateDelegate>* delegate;
}

@property (nonatomic) NSObject<MMPaperStateDelegate>* delegate;
@property (readonly) JotViewState* jotViewState;

-(id) initWithInkPath:(NSString*)inkPath andPlistPath:(NSString*)plistPath;

-(BOOL) isStateLoaded;

-(void) loadStateAsynchronously:(BOOL)async withSize:(CGSize)pagePixelSize andContext:(JotGLContext*)context andStartPage:(BOOL)startPage;

-(void) unload;

-(BOOL) hasEditsToSave;

-(void) wasSavedAtImmutableState:(JotViewImmutableState*)immutableState;

@end
