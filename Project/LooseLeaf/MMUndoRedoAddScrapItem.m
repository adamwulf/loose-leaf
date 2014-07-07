//
//  MMUndoRedoAddScrapItem.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/5/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMUndoRedoAddScrapItem.h"
#import "MMUndoablePaperView.h"

@implementation MMUndoRedoAddScrapItem{
    NSDictionary* propertiesWhenAdded;
    MMScrapView* scrap;
}

@synthesize scrap;

+(id) itemForPage:(MMUndoablePaperView*)_page andScrap:(MMScrapView*)scrap{
    return [[MMUndoRedoAddScrapItem alloc] initForPage:_page andScrap:scrap];
}

-(id) initForPage:(MMUndoablePaperView*)_page andScrap:(MMScrapView*)_scrap{
    __weak MMUndoablePaperView* weakPage = _page;
    propertiesWhenAdded = [scrap propertiesDictionary];
    if(self = [super initWithUndoBlock:^{
        [weakPage removeScrap:scrap];
    } andRedoBlock:^{
        [weakPage addScrap:scrap];
        [scrap setPropertiesDictionary:propertiesWhenAdded];
        NSUInteger subviewIndex = [[propertiesWhenAdded objectForKey:@"subviewIndex"] unsignedIntegerValue];
        [scrap.superview insertSubview:scrap atIndex:subviewIndex];
    } forPage:_page]){
        scrap = _scrap;
    };
    return self;
}


#pragma mark - Serialize

-(NSDictionary*) asDictionary{
    return [NSDictionary dictionary];
}

-(id) initFromDictionary:(NSDictionary*)dict forPage:(MMUndoablePaperView*)_page{
    if(self = [self initForPage:_page andScrap:nil]){
        canUndo = [[dict objectForKey:@"canUndo"] boolValue];
    }
    return self;
}

@end
