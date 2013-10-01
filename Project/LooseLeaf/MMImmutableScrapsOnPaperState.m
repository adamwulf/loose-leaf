//
//  MMImmutableScrapState.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/30/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMImmutableScrapsOnPaperState.h"
#import "MMScrapView.h"

@implementation MMImmutableScrapsOnPaperState{
    NSArray* scraps;
}

-(id) initWithScrapIDsPath:(NSString *)scrapIDsPath andScraps:(NSArray*)_scraps{
    if(self = [super initWithScrapIDsPath:scrapIDsPath]){
        scraps = [_scraps copy];
    }
    return self;
}

-(BOOL) isStateLoaded{
    return YES;
}

-(void) saveToDisk{
    if([scraps count]){
        NSMutableArray* scrapUUIDs = [NSMutableArray array];
        for(MMScrapView* scrap in scraps){
            NSMutableDictionary* properties = [NSMutableDictionary dictionary];
            [properties setObject:scrap.uuid forKey:@"uuid"];
            [properties setObject:[NSNumber numberWithFloat:scrap.center.x] forKey:@"center.x"];
            [properties setObject:[NSNumber numberWithFloat:scrap.center.y] forKey:@"center.y"];
            [properties setObject:[NSNumber numberWithFloat:scrap.rotation] forKey:@"rotation"];
            [properties setObject:[NSNumber numberWithFloat:scrap.scale] forKey:@"scale"];
            
            [scrap saveToDisk];
            
            // save scraps
            [scrapUUIDs addObject:properties];
        }
        [scrapUUIDs writeToFile:self.scrapIDsPath atomically:YES];
    }else{
        [[NSFileManager defaultManager] removeItemAtPath:self.scrapIDsPath error:nil];
    }
}

-(void) unload{
    if([self isStateLoaded]){
        [self saveToDisk];
    }
    [super unload];
}

@end
