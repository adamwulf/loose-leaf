//
//  MMUndoRedoPageBackgroundItem.m
//  LooseLeaf
//
//  Created by Adam Wulf on 4/3/17.
//  Copyright © 2017 Milestone Made, LLC. All rights reserved.
//

#import "MMUndoRedoPageBackgroundItem.h"
#import "MMBackgroundPatternView.h"
#import "MMTrashManager.h"

@implementation MMUndoRedoPageBackgroundItem{
    NSDictionary* originalProperties;
    NSDictionary* updatedProperties;
}

@dynamic page;

+ (id) itemForPage:(MMBackgroundedPaperView *)page andOriginalBackground:(NSDictionary *)originalProps andUpdatedBackground:(NSDictionary *)updatedProps{
    return [[MMUndoRedoPageBackgroundItem alloc] initForPage:page andOriginalBackground:originalProps andUpdatedBackground:updatedProps];
}

- (id)initForPage:(MMBackgroundedPaperView*)_page andOriginalBackground:(NSDictionary *)originalProps andUpdatedBackground:(NSDictionary *)updatedProps{
    __weak MMUndoRedoPageBackgroundItem* weakSelf = self;
    if (self = [super initWithUndoBlock:^{
        MMBackgroundPatternView* originalBackground = [MMBackgroundPatternView viewForFrame:page.originalUnscaledBounds andProperties:originalProperties];
        
        [weakSelf.page setRuledOrGridBackgroundView:originalBackground];
    } andRedoBlock:^{
        MMBackgroundPatternView* updatedBackground = [MMBackgroundPatternView viewForFrame:page.originalUnscaledBounds andProperties:updatedProperties];
        
        [weakSelf.page setRuledOrGridBackgroundView:updatedBackground];
    } forPage:_page]) {
        originalProperties = originalProps;
        updatedProperties = updatedProps;
    };
    return self;
}

#pragma mark - Finalize

- (void)finalizeUndoableState {
    // noop
}

- (void)finalizeRedoableState {
    // noop
}

#pragma mark - Serialize

- (NSDictionary*)asDictionary {
    NSMutableDictionary* propertiesDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:NSStringFromClass([self class]), @"class",
                                                 [NSNumber numberWithBool:self.canUndo], @"canUndo", nil];
    if(originalProperties){
        [propertiesDictionary setObject:originalProperties forKey:@"originalProperties"];
    }
    if(updatedProperties){
        [propertiesDictionary setObject:updatedProperties forKey:@"updatedProperties"];
    }
    
    return propertiesDictionary;
}

- (id)initFromDictionary:(NSDictionary*)dict forPage:(MMUndoablePaperView*)_page {
    NSDictionary* _originalProperties = [dict objectForKey:@"originalProperties"];
    NSDictionary* _updatedProperties = [dict objectForKey:@"updatedProperties"];
    if (self = [self initForPage:(MMBackgroundedPaperView*)_page andOriginalBackground:_originalProperties andUpdatedBackground:_updatedProperties]) {
        canUndo = [[dict objectForKey:@"canUndo"] boolValue];
    }
    return self;
}

#pragma mark - Description

- (NSString*)description {
    return [NSString stringWithFormat:@"[%@ %@ %@]", NSStringFromClass([self class]), originalProperties[@"class"], updatedProperties[@"class"]];
}

#pragma mark - Scrap Checking

- (BOOL)containsScrapUUID:(NSString*)_scrapUUID {
    return NO;
}

@end
