//
//  MMUndoRedoRemoveScrapItem.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/5/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMUndoRedoRemoveScrapItem.h"
#import "MMUndoablePaperView.h"

@implementation MMUndoRedoRemoveScrapItem{
    NSDictionary* propertiesWhenRemoved;
}

+(id) itemForPage:(MMUndoablePaperView*)_page andScrap:(MMScrapView*)scrap withProperties:(NSDictionary*)scrapProperties{
    return [[MMUndoRedoRemoveScrapItem alloc] initForPage:_page andScrap:scrap withProperties:scrapProperties];
}

-(id) initForPage:(MMUndoablePaperView*)_page andScrap:(MMScrapView*)scrap withProperties:(NSDictionary*)scrapProperties{
    __weak MMUndoablePaperView* weakPage = _page;
    propertiesWhenRemoved = scrapProperties;
    if(self = [super initWithUndoBlock:^{
        [weakPage addScrap:scrap];
        [scrap setPropertiesDictionary:propertiesWhenRemoved];
        NSUInteger subviewIndex = [[propertiesWhenRemoved objectForKey:@"subviewIndex"] unsignedIntegerValue];
        [scrap.superview insertSubview:scrap atIndex:subviewIndex];
    } andRedoBlock:^{
        [weakPage removeScrap:scrap];
    } forPage:_page]){
        // noop
    };
    return self;
}


#pragma mark - Serialize

-(NSDictionary*) asDictionary{
    return [NSDictionary dictionary];
}

-(id) initFromDictionary:(NSDictionary*)dict forPage:(MMUndoablePaperView*)_page{
    if(self = [self initForPage:_page andScrap:nil withProperties:[dict objectForKey:@"propertiesWhenRemoved"]]){
        canUndo = [[dict objectForKey:@"canUndo"] boolValue];
    }
    return self;
}

@end
