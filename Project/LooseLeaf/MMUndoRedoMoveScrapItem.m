//
//  MMUndoRedoMoveScrapItem.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/7/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMUndoRedoMoveScrapItem.h"
#import "MMUndoablePaperView.h"

@implementation MMUndoRedoMoveScrapItem{
    NSDictionary* startProperties;
    NSDictionary* endProperties;
}

+(id) itemForPage:(MMUndoablePaperView*)_page andScrap:(MMScrapView*)scrap from:(NSDictionary *)startProperties to:(NSDictionary *)endProperties{
    return [[MMUndoRedoMoveScrapItem alloc] initForPage:_page andScrap:scrap from:startProperties to:endProperties];
}

-(id) initForPage:(MMUndoablePaperView*)_page andScrap:(MMScrapView*)scrap from:(NSDictionary *)_startProperties to:(NSDictionary *)_endProperties{
    if(self = [super initWithUndoBlock:^{
        [scrap setPropertiesDictionary:startProperties];
    } andRedoBlock:^{
        [scrap setPropertiesDictionary:endProperties];
    } forPage:_page]){
        // noop
        startProperties = _startProperties;
        endProperties = _endProperties;
    };
    return self;
}


#pragma mark - Serialize

-(NSDictionary*) asDictionary{
    return [NSDictionary dictionary];
}

-(id) initFromDictionary:(NSDictionary*)dict forPage:(MMUndoablePaperView*)_page{
    if(self = [self initForPage:_page andScrap:nil from:[dict objectForKey:@"startProperties"] to:[dict objectForKey:@"endProperties"]]){
        canUndo = [[dict objectForKey:@"canUndo"] boolValue];
    }
    return self;
}

@end
